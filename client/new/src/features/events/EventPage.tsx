import Box from "@mui/material/Box";
import Tab from "@mui/material/Tab";
import Tabs from "@mui/material/Tabs";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import { useParams } from "react-router";
import { ConstrainedBody } from "@/components/ConstrainedBody";
import { ErrorState, LoadingState } from "@/components/States";
import { AgendaTab } from "@/features/content/AgendaTab";
import { PrePostTab } from "@/features/content/PrePostTab";
import {
  useClearAgenda,
  useDeleteAgendaItem,
  useEvent,
  useEventParticipants,
  useReorderAgenda,
  useUpdatePrePost,
  useUpsertAgendaItem,
} from "@/queries/events";
import { useCurrentUserId } from "@/queries/me";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { eventPermissions } from "@/utils/events/eventPermissions";
import { cardHasData } from "@/utils/prePost";
import { useIsMobile } from "@/utils/useResponsive";
import { isFacilitator } from "@/utils/membership";
import { BreakoutsSection } from "./BreakoutsSection";
import { EditTemplateNotice } from "./EditTemplateNotice";
import { EventAbout } from "./EventAbout";
import { EventInfoCard } from "./EventInfoCard";

type TabId = "about" | "agenda" | "ctas";

// `/space/:displayId/discuss/:templateId/:eventId`: the event's card (when, who, RSVP) beside what it is about.
export function EventPage() {
  const { t } = useLingui();
  const { community, status, templates } = useCommunityScope();
  const { templateId = "", eventId = "" } = useParams();
  const isMobile = useIsMobile();
  const meId = useCurrentUserId();
  const event = useEvent(community.id, templateId, eventId);
  const participants = useEventParticipants(eventId).data;
  // Tab id, not UI text.
  // eslint-disable-next-line lingui/no-unlocalized-strings
  const [tab, setTab] = useState<TabId>("about");
  const clearAgenda = useClearAgenda();
  const upsertStep = useUpsertAgendaItem();
  const deleteStep = useDeleteAgendaItem();
  const reorderSteps = useReorderAgenda();
  const updatePrePost = useUpdatePrePost();

  if (event.isPending) return <LoadingState height={400} />;
  if (event.isError) {
    return (
      <ErrorState
        height={400}
        message={t({
          id: "eventNotFound",
          message: "This event could not be found.",
        })}
      />
    );
  }

  const isParticipant = !!participants?.some(
    ({ participant, user }) =>
      user.id === meId && participant.status === "active",
  );
  const { canEdit, isHost } = eventPermissions({
    event: event.data,
    userId: meId,
    status,
    settings: community.settings,
    isParticipant,
  });
  const hasPrePost =
    cardHasData(event.data.preEventCard) ||
    cardHasData(event.data.postEventCard);
  // Hosts set the cards up; participants only see them once there is something to see.
  // The agenda is public unless the host turned previews off; hosts and facilitators always see it.
  const settings =
    event.data.eventSettings ??
    templates.find((candidate) => candidate.id === event.data.templateId)
      ?.eventSettings ??
    community.eventSettings;
  const showAgenda =
    (settings.agendaPreview ?? false) || isHost || isFacilitator(status);
  const showCtas = canEdit || (isParticipant && hasPrePost);
  const current: TabId =
    (tab === "ctas" && !showCtas) || (tab === "agenda" && !showAgenda)
      ? "about"
      : tab;

  return (
    <>
      <EditTemplateNotice event={event.data} />
      <Box component="main" sx={{ pt: isMobile ? "20px" : "40px", pb: "80px" }}>
        <ConstrainedBody>
          <Box
            sx={{
              display: "flex",
              flexDirection: isMobile ? "column" : "row",
              alignItems: "flex-start",
              gap: "40px",
            }}
          >
            <Box sx={{ width: isMobile ? "100%" : 400, flexShrink: 0 }}>
              <EventInfoCard event={event.data} />
            </Box>
            <Box
              sx={{ flex: 1, minWidth: 0, width: isMobile ? "100%" : "auto" }}
            >
              <Tabs
                value={current}
                onChange={(_change, next: TabId) => setTab(next)}
                variant="scrollable"
              >
                <Tab
                  value="about"
                  label={t({ id: "about", message: "About" })}
                  sx={{ textTransform: "uppercase" }}
                />
                {showAgenda && (
                  <Tab
                    value="agenda"
                    label={t({ id: "agendaTab", message: "Agenda" })}
                    sx={{ textTransform: "uppercase" }}
                  />
                )}
                {showCtas && (
                  <Tab
                    value="ctas"
                    label={t({ id: "ctasTab", message: "CTAs" })}
                    sx={{ textTransform: "uppercase" }}
                  />
                )}
              </Tabs>
              {current === "about" && <EventAbout event={event.data} />}
              {current === "agenda" && (
                <AgendaTab
                  items={event.data.agendaItems}
                  canEdit={canEdit}
                  startsCollapsed
                  above={
                    canEdit ? (
                      <BreakoutsSection event={event.data} />
                    ) : undefined
                  }
                  actions={{
                    save: (item) =>
                      upsertStep.mutateAsync({ event: event.data, item }),
                    remove: (itemId) =>
                      deleteStep.mutateAsync({ event: event.data, itemId }),
                    reorder: (ids) =>
                      reorderSteps.mutateAsync({ event: event.data, ids }),
                    clear: () => clearAgenda.mutateAsync({ event: event.data }),
                  }}
                />
              )}
              {current === "ctas" && (
                <PrePostTab
                  pre={event.data.preEventCard}
                  post={event.data.postEventCard}
                  canEdit={canEdit}
                  event={event.data}
                  onSave={(which, card) =>
                    updatePrePost.mutateAsync({
                      event: event.data,
                      which,
                      card,
                    })
                  }
                />
              )}
            </Box>
          </Box>
        </ConstrainedBody>
      </Box>
    </>
  );
}
