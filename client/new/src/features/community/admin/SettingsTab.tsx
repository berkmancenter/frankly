import Box from "@mui/material/Box";
import CircularProgress from "@mui/material/CircularProgress";
import Divider from "@mui/material/Divider";
import Switch from "@mui/material/Switch";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { Fragment, useId, useState, type ReactNode } from "react";
import {
  ALL_EVENT_SETTING_FLAGS,
  type CommunitySettings,
  type EventSettings,
  type AnyEventSettingFlag,
} from "@/api/types";
import { useToast } from "@/components/Toast";
import { useUpdateCommunity } from "@/queries/communities";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { colors, fontSizes } from "@/theme/tokens";
import { enableDevAdminSettings } from "@/utils/appInfo";
import { humanizeKey } from "@/utils/strings";
import { useIsMobile } from "@/utils/useResponsive";

interface Toggle {
  /** Identifies the switch while its change is saving. */
  id: string;
  label: string;
  on: boolean;
  /** Saves the opposite of the current value. */
  flip: () => Promise<unknown>;
  help?: string;
}

// Settings that default to on when the community has never set them.
const flagOn = (settings: EventSettings, flag: AnyEventSettingFlag) =>
  settings[flag] ?? true;

// The Settings tab: switches for who may do what in the community and how its events start out.
export function SettingsTab() {
  const { t } = useLingui();
  const { community } = useCommunityScope();
  const toast = useToast();
  const update = useUpdateCommunity();
  const [saving, setSaving] = useState<Set<string>>(new Set());

  // One change at a time per switch, so a double click cannot save the same flip twice.
  const run =
    (id: string, patch: Parameters<typeof update.mutateAsync>[0]["patch"]) =>
    async () => {
      if (saving.has(id)) return;
      setSaving((current) => new Set(current).add(id));
      try {
        await update.mutateAsync({ community, patch });
      } catch {
        toast.error(
          t({
            id: "somethingWentWrongTryAgain",
            message: "Something went wrong. Please try again.",
          }),
        );
      } finally {
        setSaving((current) => {
          const next = new Set(current);
          next.delete(id);
          return next;
        });
      }
    };

  const { settings, eventSettings } = community;
  const setting = <K extends keyof CommunitySettings>(
    key: K,
    value: CommunitySettings[K],
  ) => run(key, { settings: { ...settings, [key]: value } });
  const eventSetting = (flag: AnyEventSettingFlag, value: boolean) =>
    run(flag, { eventSettings: { ...eventSettings, [flag]: value } });

  const communityToggles: Toggle[] = [
    {
      id: "dontAllowMembersToCreateMeetings",
      label: t({
        id: "settingAllowMembersToCreateEvents",
        message: "Allow members to create events",
      }),
      help: t({
        id: "settingHelperMemberEvents",
        message:
          "Enables community members to create and host events using your community's templates.",
      }),
      on: !settings.dontAllowMembersToCreateMeetings,
      flip: setting(
        "dontAllowMembersToCreateMeetings",
        !settings.dontAllowMembersToCreateMeetings,
      ),
    },
    {
      id: "allowUnofficialTemplates",
      label: t({
        id: "settingAllowMembersToCreateTemplates",
        message: "Allow members to create templates",
      }),
      help: t({
        id: "settingHelperMemberTemplates",
        message:
          "Permits members to build and save reusable event templates within your community.",
      }),
      on: settings.allowUnofficialTemplates,
      flip: setting(
        "allowUnofficialTemplates",
        !settings.allowUnofficialTemplates,
      ),
    },
    {
      id: "requireApprovalToJoin",
      label: t({
        id: "settingRequireApprovalForNewMembers",
        message: "Require approval for new members",
      }),
      help: t({
        id: "settingHelperRequireMembershipApproval",
        message:
          "All membership requests must be reviewed and approved by community administrators before access is granted. Event participation will be restricted to members.",
      }),
      on: settings.requireApprovalToJoin,
      flip: setting("requireApprovalToJoin", !settings.requireApprovalToJoin),
    },
    {
      id: "disableEmailDigests",
      label: t({
        id: "settingEnableWeeklyEmailDigestsOfUpcomingEvents",
        message: "Enable weekly email digests of upcoming events",
      }),
      help: t({
        id: "settingHelperEnableWeeklyEmail",
        message:
          "Automatically sends members a weekly summary of upcoming events to keep them informed and engaged.",
      }),
      on: !settings.disableEmailDigests,
      flip: setting("disableEmailDigests", !settings.disableEmailDigests),
    },
  ];

  const eventToggle = (
    flag: AnyEventSettingFlag,
    label: string,
    help: string,
  ): Toggle => ({
    id: flag,
    label,
    help,
    on: flagOn(eventSettings, flag),
    flip: eventSetting(flag, !flagOn(eventSettings, flag)),
  });
  const eventToggles: Toggle[] = [
    eventToggle(
      "chat",
      t({ id: "chat", message: "Chat" }),
      t({
        id: "settingHelperChat",
        message:
          "Enables participant messaging on event landing pages and during events, including within breakouts.",
      }),
    ),
    eventToggle(
      "showChatMessagesInRealTime",
      t({ id: "floatingChat", message: "Floating Chat" }),
      t({
        id: "settingHelperFloatingChat",
        message:
          "Shows temporary chat notification bubbles at the bottom of the screen during events.",
      }),
    ),
    eventToggle(
      "alwaysRecord",
      t({ id: "record", message: "Recording" }),
      t({
        id: "settingHelperRecord",
        message:
          "Captures video from the event that admins can download later. (Currently limited to main room recordings in hosted events; breakout recordings coming soon.)",
      }),
    ),
    eventToggle(
      "talkingTimer",
      t({ id: "odometer", message: "Odometer" }),
      t({
        id: "settingHelperTalkTimer",
        message:
          "Displays speaking time indicator to participants and provides gentle nudges to encourage balanced discussion.",
      }),
    ),
    eventToggle(
      "agendaPreview",
      t({ id: "settingAgendaPreview", message: "Agenda Preview" }),
      t({
        id: "settingHelperAgendaPreview",
        message:
          "Makes event agenda visible on the event landing page. When disabled, agenda is only visible within the event session.",
      }),
    ),
  ];

  const devCommunityToggles: Toggle[] = (
    Object.keys(settings) as (keyof CommunitySettings)[]
  )
    .filter((key) => typeof settings[key] === "boolean")
    .map((key) => ({
      id: key,
      label: humanizeKey(key),
      on: settings[key] as boolean,
      flip: setting(key, !settings[key]),
    }));
  const devEventToggles: Toggle[] = ALL_EVENT_SETTING_FLAGS.map((flag) => ({
    id: flag,
    label: humanizeKey(flag),
    on: flagOn(eventSettings, flag),
    flip: eventSetting(flag, !flagOn(eventSettings, flag)),
  }));

  return (
    <Box>
      <SettingsSection
        title={t({ id: "communitySettings", message: "Community Settings" })}
        toggles={communityToggles}
        saving={saving}
      />
      <Divider sx={{ my: "30px", borderColor: colors.onPrimaryContainer }} />
      <SettingsSection
        title={t({ id: "eventSettings", message: "Event Settings" })}
        description={t({
          id: "eventSettingsDescription",
          message:
            "Define default settings for events within your community. These can be overridden for individual events and templates.",
        })}
        toggles={eventToggles}
        saving={saving}
      />
      {enableDevAdminSettings() && (
        <Box component="section" sx={{ pt: "30px" }}>
          <Divider
            sx={{ mb: "30px", borderColor: colors.onPrimaryContainer }}
          />
          <Typography component="h2" sx={{ fontSize: fontSizes["3xl"] }}>
            {t({ id: "devSettings", message: "Developer Settings" })}
          </Typography>
          <SettingsSection
            title={t({
              id: "communitySettings",
              message: "Community Settings",
            })}
            toggles={devCommunityToggles}
            saving={saving}
          />
          <Divider
            sx={{ my: "30px", borderColor: colors.onPrimaryContainer }}
          />
          <SettingsSection
            title={t({ id: "eventSettings", message: "Event Settings" })}
            toggles={devEventToggles}
            saving={saving}
          />
        </Box>
      )}
    </Box>
  );
}

// A heading and its switches: side by side on a wide screen, stacked on a phone.
function SettingsSection({
  title,
  description,
  toggles,
  saving,
}: {
  title: string;
  description?: string;
  toggles: Toggle[];
  saving: ReadonlySet<string>;
}) {
  const isMobile = useIsMobile();
  return (
    <Box
      component="section"
      aria-label={title}
      sx={{
        display: isMobile ? "block" : "grid",
        gridTemplateColumns: "2fr 4fr",
        alignItems: "start",
        gap: "46px",
      }}
    >
      <Box sx={{ px: isMobile ? "8px" : "46px", py: "28px" }}>
        <Typography component="h2" sx={{ fontSize: fontSizes.xl }}>
          {title}
        </Typography>
        {description && (
          <Typography variant="body2" sx={{ pt: "10px" }}>
            {description}
          </Typography>
        )}
      </Box>
      <Box sx={{ pt: isMobile ? 0 : "28px" }}>
        <Card>
          {toggles.map((toggle, index) => (
            <Fragment key={toggle.id}>
              <SwitchRow toggle={toggle} saving={saving.has(toggle.id)} />
              {index < toggles.length - 1 && <Divider sx={{ mx: "16px" }} />}
            </Fragment>
          ))}
        </Card>
      </Box>
    </Box>
  );
}

function Card({ children }: { children: ReactNode }) {
  return (
    <Box
      sx={{
        bgcolor: "rgba(255,255,255,.7)",
        borderRadius: "16px",
        overflow: "hidden",
      }}
    >
      {children}
    </Box>
  );
}

function SwitchRow({ toggle, saving }: { toggle: Toggle; saving: boolean }) {
  const inputId = useId();
  return (
    <Box sx={{ px: "16px", py: "12px" }}>
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          gap: "16px",
        }}
      >
        <Typography
          component="label"
          htmlFor={inputId}
          sx={{ flex: 1, cursor: "pointer" }}
        >
          {toggle.label}
        </Typography>
        {saving ? (
          <CircularProgress
            size={24}
            aria-label={toggle.label}
            sx={{ mx: "9px" }}
          />
        ) : (
          <Switch
            id={inputId}
            checked={toggle.on}
            onChange={() => void toggle.flip()}
          />
        )}
      </Box>
      {toggle.help && (
        <Typography
          variant="body2"
          sx={{ pt: "4px", pr: "28px", color: colors.onSurfaceVariant }}
        >
          {toggle.help}
        </Typography>
      )}
    </Box>
  );
}
