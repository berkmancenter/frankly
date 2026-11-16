import Box from "@mui/material/Box";
import Checkbox from "@mui/material/Checkbox";
import FormControlLabel from "@mui/material/FormControlLabel";
import MenuItem from "@mui/material/MenuItem";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import type { Community, Membership } from "@/api/types";
import { ErrorState, LoadingState } from "@/components/States";
import { useToast } from "@/components/Toast";
import { useMyCommunities } from "@/queries/communities";
import { useMe } from "@/queries/me";
import { useNotificationSettings, useUpdateNotificationSettings } from "@/queries/profile";
import { colors } from "@/theme/tokens";
import { isMember } from "@/utils/membership";

// Owners first, then down to plain members.
// Membership status identifiers, not UI text.
// eslint-disable-next-line lingui/no-unlocalized-strings
const ORDER = ["owner", "admin", "moderator", "facilitator", "member"];
const rank = (membership: Membership) => ORDER.indexOf(membership.status);

// The notifications tab: pick one of your communities, then choose which emails it may send.
export function NotificationsTab({ initialCommunityId }: { initialCommunityId?: string }) {
  const { t } = useLingui();
  const me = useMe();
  const communities = useMyCommunities();
  const [chosen, setChosen] = useState<string>();

  if (me.isPending || communities.isPending) return <LoadingState height={200} />;
  if (me.isError || communities.isError) {
    return (
      <ErrorState
        message={t({
          id: "errorLoadingMemberships",
          message: "Something went wrong loading your memberships. Please refresh.",
        })}
      />
    );
  }

  const memberships = me.data.memberships
    .filter((membership) => isMember(membership.status))
    .sort((a, b) => rank(a) - rank(b));
  if (memberships.length === 0) {
    return <Typography sx={{ p: "20px" }}>{t`You aren't a member of any communities.`}</Typography>;
  }

  const names = new Map(communities.data.map((community: Community) => [community.id, community.name]));
  const known = (id?: string) => memberships.some((membership) => membership.communityId === id);
  const active = known(chosen)
    ? chosen!
    : known(initialCommunityId)
      ? initialCommunityId!
      : memberships[0].communityId;

  return (
    <Box sx={{ maxWidth: 540, minWidth: 280, width: "100%" }}>
      <TextField
        select
        fullWidth
        label={t({ id: "selectSpace", message: "Select space:" })}
        value={active}
        onChange={(event) => setChosen(event.target.value)}
        sx={{ my: "20px" }}
      >
        {memberships.map((membership) => (
          <MenuItem key={membership.communityId} value={membership.communityId}>
            {names.get(membership.communityId) ?? membership.communityId}
          </MenuItem>
        ))}
      </TextField>
      <CommunitySettings
        key={active}
        communityId={active}
        communityName={names.get(active) ?? active}
      />
    </Box>
  );
}

function CommunitySettings({
  communityId,
  communityName,
}: {
  communityId: string;
  communityName: string;
}) {
  const { t } = useLingui();
  const toast = useToast();
  const settings = useNotificationSettings(communityId);
  const update = useUpdateNotificationSettings(communityId);

  if (settings.isPending) return <LoadingState height={100} />;
  if (settings.isError) {
    return (
      <ErrorState
        message={t({
          id: "errorLoadingNotificationSettings",
          message: "Something went wrong loading notification settings. Please refresh.",
        })}
      />
    );
  }

  const toggle = (key: "notifyAnnouncements" | "notifyEvents") => async (checked: boolean) => {
    try {
      await update.mutateAsync({ [key]: checked });
    } catch {
      toast.error(t`Something went wrong. Please try again.`);
    }
  };

  return (
    <Box
      sx={{
        p: "20px",
        border: "1px solid",
        borderColor: colors.outlineVariant,
        borderRadius: "10px",
      }}
    >
      <Typography sx={{ pb: "12px", color: colors.onSurfaceVariant }}>
        {t({
          id: "settingsFor",
          message: `Settings for ${communityName}`,
        })}
      </Typography>
      <Box sx={{ display: "flex", flexDirection: "column" }}>
        <FormControlLabel
          label={t({
            id: "notifyMeAboutNewAnnouncements",
            message: "Notify me about new announcements",
          })}
          control={
            <Checkbox
              checked={settings.data.notifyAnnouncements}
              onChange={(_, checked) => void toggle("notifyAnnouncements")(checked)}
            />
          }
        />
        <FormControlLabel
          label={t({ id: "notifyMeAboutNewEvents", message: "Notify me about new events" })}
          control={
            <Checkbox
              checked={settings.data.notifyEvents}
              onChange={(_, checked) => void toggle("notifyEvents")(checked)}
            />
          }
        />
      </Box>
    </Box>
  );
}
