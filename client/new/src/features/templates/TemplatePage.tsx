import Box from "@mui/material/Box";
import FormControlLabel from "@mui/material/FormControlLabel";
import Radio from "@mui/material/Radio";
import RadioGroup from "@mui/material/RadioGroup";
import Tab from "@mui/material/Tab";
import Tabs from "@mui/material/Tabs";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import { useParams } from "react-router";
import type { EventType } from "@/api/types";
import { paths } from "@/app/paths";
import { ActionButton } from "@/components/ActionButton";
import { ConstrainedBody } from "@/components/ConstrainedBody";
import { EventCard } from "@/components/events/EventCards";
import { Img } from "@/components/Img";
import { ErrorState, LoadingState } from "@/components/States";
import { TemplateCard } from "@/components/TemplateCard";
import { AgendaTab } from "@/features/content/AgendaTab";
import { PrePostTab } from "@/features/content/PrePostTab";
import { useCreateEventDialog } from "@/features/events/CreateEventDialog";
import { usePrePostEnabled } from "@/queries/communities";
import { useCurrentUserId } from "@/queries/me";
import { useTemplateTags } from "@/queries/tags";
import {
  useClearTemplateAgenda,
  useDeleteTemplateAgendaItem,
  useHasAttendedTemplate,
  useTemplate,
  useReorderTemplateAgenda,
  useTemplateEvents,
  useUpdateTemplatePrePost,
  useUpsertTemplateAgendaItem,
} from "@/queries/templates";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { colors, fontSizes } from "@/theme/tokens";
import { freeText, wrapAnywhere } from "@/theme/freeText";
import { isAdmin, isMod } from "@/utils/membership";
import { useIsMobile } from "@/utils/useResponsive";

type TabId = "about" | "agenda" | "events" | "ctas";

const MORE_TEMPLATES = 5;
const EVENTS_SHOWN = 40;

// `/space/:displayId/discuss/:templateId`: what a template is, its plan, and the events coming up from it.
export function TemplatePage() {
  const { t } = useLingui();
  const { community, status, permissions, templates } = useCommunityScope();
  const { templateId = "" } = useParams();
  const isMobile = useIsMobile();
  const meId = useCurrentUserId();
  const template = useTemplate(community.id, templateId);
  const events = useTemplateEvents(community.id, templateId);
  const tags = (useTemplateTags(community.id).data ?? []).filter(
    (entry) => entry.templateId === templateId,
  );
  const attended = useHasAttendedTemplate(
    template.data?.prerequisiteTemplateId,
  );
  const admin = isAdmin(status);
  const prePostEnabled = usePrePostEnabled(community.id, admin).data === true;
  const createEvent = useCreateEventDialog();
  const updatePrePost = useUpdateTemplatePrePost();
  const clearAgenda = useClearTemplateAgenda();
  const upsertStep = useUpsertTemplateAgendaItem();
  const deleteStep = useDeleteTemplateAgendaItem();
  const reorderSteps = useReorderTemplateAgenda();
  // Tab id, not UI text.
  // Tab and event type ids, not UI text.
  /* eslint-disable lingui/no-unlocalized-strings */
  const [tab, setTab] = useState<TabId>("about");
  const [eventType, setEventType] = useState<EventType>("hosted");
  /* eslint-enable lingui/no-unlocalized-strings */

  if (template.isPending) return <LoadingState height={400} />;
  if (template.isError) {
    return (
      <ErrorState
        height={400}
        message={t({
          id: "templateNotFound",
          message: "This template could not be found.",
        })}
      />
    );
  }
  const data = template.data;

  // Its creator and moderators may change a template.
  const canEdit =
    (!!data.creatorId && data.creatorId === meId) || isMod(status);
  const showCtas = admin && prePostEnabled;
  const current: TabId = tab === "ctas" && !showCtas ? "about" : tab;
  const unmetPrerequisite =
    !!data.prerequisiteTemplateId && attended.data !== true && !canEdit;
  const upcoming = events.data ?? [];
  const others = templates
    .filter((candidate) => candidate.id !== data.id)
    .slice(0, MORE_TEMPLATES);
  const communityName = community.name;
  // Hostless events can be turned off per community; the others are always offered.
  const hostingTypes: { type: EventType; label: string }[] = [
    { type: "hosted", label: t({ id: "hosted", message: "Hosted" }) },
    ...(community.settings.enableHostless
      ? [
          {
            type: "hostless" as const,
            label: t({ id: "hostless", message: "Hostless" }),
          },
        ]
      : []),
    {
      type: "livestream",
      label: t({ id: "livestream", message: "Livestream" }),
    },
  ];

  const newEventCard = permissions.canCreateEvent && (
    <Box
      sx={{
        border: 1,
        borderColor: colors.outlineVariant,
        borderRadius: "12px",
        bgcolor: colors.surfaceContainerLowest,
        p: "20px",
        display: "flex",
        flexDirection: "column",
        gap: "16px",
        width: isMobile ? "100%" : 350,
        flexShrink: 0,
      }}
    >
      <Typography
        component="h2"
        sx={{ fontSize: fontSizes.lg, fontWeight: 500 }}
      >
        {t({
          id: "createEventFromThisTemplate",
          message: "Create an event from this template",
        })}
      </Typography>
      <RadioGroup
        aria-label={t({ id: "eventHostingType", message: "Type of event" })}
        value={eventType}
        onChange={(change) => setEventType(change.target.value as EventType)}
      >
        {hostingTypes.map(({ type, label }) => (
          <FormControlLabel
            key={type}
            value={type}
            control={<Radio />}
            label={label}
          />
        ))}
      </RadioGroup>
      {unmetPrerequisite && (
        <Typography sx={{ color: colors.error, fontWeight: 700 }}>
          {t({ id: "prereqRequired", message: "Prerequisite required" })}
        </Typography>
      )}
      <ActionButton
        expand
        disabled={unmetPrerequisite}
        onPress={() =>
          createEvent.open({
            template: data,
            isPublic: false,
            eventType,
            durationInMinutes: 60,
          })
        }
      >
        {t({ id: "createEventButton", message: "Create event" })}
      </ActionButton>
      {createEvent.dialog}
    </Box>
  );

  return (
    <Box component="main" sx={{ pb: "100px" }}>
      <Box sx={{ bgcolor: colors.surfaceContainer }}>
        <ConstrainedBody>
          <Box
            sx={{
              display: "flex",
              gap: "20px",
              alignItems: "center",
              pt: "30px",
              pb: "20px",
            }}
          >
            <Img
              src={data.image}
              width={isMobile ? 80 : 120}
              height={isMobile ? 80 : 120}
              radius={20}
              alt=""
            />
            <Box sx={{ minWidth: 0 }}>
              <Typography
                component="h1"
                sx={{
                  fontSize: fontSizes["3xl"],
                  lineHeight: 1.2,
                  color: "primary.main",
                  ...wrapAnywhere,
                }}
              >
                {data.title}
              </Typography>
              {data.category && (
                <Typography sx={{ color: colors.onSurfaceVariant }}>
                  {data.category}
                </Typography>
              )}
              {tags.length > 0 && (
                <Typography sx={{ color: colors.onSurfaceVariant }}>
                  {tags.map(({ tag }) => `#${tag.title}`).join(" ")}
                </Typography>
              )}
            </Box>
          </Box>
          <Tabs
            value={current}
            onChange={(_change, next: TabId) => setTab(next)}
            variant="scrollable"
          >
            <Tab value="about" label={t({ id: "about", message: "About" })} />
            <Tab
              value="agenda"
              label={t({ id: "agendaTab", message: "Agenda" })}
            />
            <Tab
              value="events"
              label={t({ id: "upcomingEvents", message: "Upcoming Events" })}
            />
            {showCtas && (
              <Tab value="ctas" label={t({ id: "ctasTab", message: "CTAs" })} />
            )}
          </Tabs>
        </ConstrainedBody>
      </Box>
      <ConstrainedBody sx={{ pt: "20px" }}>
        <Box
          sx={{
            display: "flex",
            flexDirection: isMobile ? "column" : "row",
            alignItems: "flex-start",
            gap: "25px",
          }}
        >
          <Box sx={{ flex: 1, minWidth: 0, width: isMobile ? "100%" : "auto" }}>
            {current === "about" && (
              <Box
                sx={{
                  display: "flex",
                  flexDirection: "column",
                  gap: "40px",
                  pt: "20px",
                }}
              >
                <Box component="section">
                  <Typography
                    component="h3"
                    sx={{ fontSize: fontSizes.md, fontWeight: 700, mb: "10px" }}
                  >
                    {t({ id: "description", message: "Description" })}
                  </Typography>
                  <Typography sx={freeText}>
                    {data.description ||
                      t({
                        id: "noDescriptionForEvent",
                        message: "No description for this event",
                      })}
                  </Typography>
                </Box>
                <Box component="section">
                  <Box
                    sx={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                    }}
                  >
                    <Typography
                      component="h3"
                      sx={{ fontSize: fontSizes.md, fontWeight: 700 }}
                    >
                      {t({ id: "upcomingEvents", message: "Upcoming Events" })}
                    </Typography>
                    {upcoming.length > 0 && (
                      <ActionButton
                        type="text"
                        // Tab id, not UI text.
                        // eslint-disable-next-line lingui/no-unlocalized-strings
                        onPress={() => setTab("events")}
                      >
                        {t({ id: "seeAll", message: "See all" })}
                      </ActionButton>
                    )}
                  </Box>
                  {events.isError ? (
                    <Typography>
                      {t({
                        id: "somethingWentWrongLoadingEvents",
                        message: "Something went wrong loading events.",
                      })}
                    </Typography>
                  ) : upcoming.length === 0 ? (
                    <Typography sx={{ mt: "10px" }}>
                      {t({
                        id: "noUpcomingEvents",
                        message: "No upcoming events.",
                      })}
                    </Typography>
                  ) : (
                    <Box sx={{ mt: "20px" }}>
                      <EventCard event={upcoming[0]!} />
                    </Box>
                  )}
                </Box>
                {others.length > 0 && (
                  <Box component="section">
                    <Typography
                      component="h3"
                      sx={{
                        fontSize: fontSizes.md,
                        fontWeight: 700,
                        mb: "10px",
                      }}
                    >
                      {t({
                        id: "moreFromName",
                        message: `More from ${communityName}`,
                      })}
                    </Typography>
                    <Box
                      sx={{ display: "flex", flexWrap: "wrap", gap: "16px" }}
                    >
                      {others.map((other) => (
                        <TemplateCard
                          key={other.id}
                          template={other}
                          to={paths
                            .community(community.displayId)
                            .template(other.id)}
                        />
                      ))}
                    </Box>
                  </Box>
                )}
              </Box>
            )}
            {current === "agenda" && (
              <AgendaTab
                items={data.agendaItems}
                canEdit={canEdit}
                actions={{
                  save: (item) =>
                    upsertStep.mutateAsync({ template: data, item }),
                  remove: (itemId) =>
                    deleteStep.mutateAsync({ template: data, itemId }),
                  reorder: (ids) =>
                    reorderSteps.mutateAsync({ template: data, ids }),
                  clear: () => clearAgenda.mutateAsync({ template: data }),
                }}
              />
            )}
            {current === "events" && (
              <Box
                sx={{
                  display: "flex",
                  flexDirection: "column",
                  gap: "14px",
                  pt: "30px",
                }}
              >
                {upcoming.length === 0 ? (
                  <>
                    <Typography component="h3" sx={{ fontSize: fontSizes.lg }}>
                      {t({ id: "noEvents", message: "No events" })}
                    </Typography>
                    <Typography sx={{ color: colors.onSurfaceVariant }}>
                      {t({
                        id: "whenNewEventsAreAdded",
                        message:
                          "When new events are added, you’ll see them here.",
                      })}
                    </Typography>
                  </>
                ) : (
                  upcoming
                    .slice(0, EVENTS_SHOWN)
                    .map((event) => <EventCard key={event.id} event={event} />)
                )}
              </Box>
            )}
            {current === "ctas" && (
              <PrePostTab
                pre={data.preEventCard}
                post={data.postEventCard}
                canEdit={canEdit}
                onSave={(which, card) =>
                  updatePrePost.mutateAsync({ template: data, which, card })
                }
              />
            )}
          </Box>
          {newEventCard}
        </Box>
      </ConstrainedBody>
    </Box>
  );
}
