import CloseIcon from "@mui/icons-material/Close";
import Box from "@mui/material/Box";
import IconButton from "@mui/material/IconButton";
import Link from "@mui/material/Link";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import { Link as RouterLink } from "react-router";
import type { Event } from "@/api/types";
import { paths } from "@/app/paths";
import { ConstrainedBody } from "@/components/ConstrainedBody";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { colors } from "@/theme/tokens";
import { DEFAULT_TEMPLATE_ID } from "@/utils/events/eventTiming";
import { isMod } from "@/utils/membership";

// A moderator who dismissed the notice does not see it again on this browser.
const HIDDEN_KEY = "editTemplateNoticeHidden";

const wasHidden = (): boolean => {
  try {
    return localStorage.getItem(HIDDEN_KEY) === "true";
  } catch {
    return false;
  }
};

// Reminds moderators that edits to an event stay with that event, and points to the template for changes to future ones.
export function EditTemplateNotice({ event }: { event: Event }) {
  const { t } = useLingui();
  const { community, status } = useCommunityScope();
  const [hidden, setHidden] = useState(wasHidden);

  if (hidden || event.templateId === DEFAULT_TEMPLATE_ID || !isMod(status))
    return null;

  const hide = () => {
    setHidden(true);
    try {
      // Stored flag value, not UI text.
      // eslint-disable-next-line lingui/no-unlocalized-strings
      localStorage.setItem(HIDDEN_KEY, "true");
    } catch {
      /* storage unavailable: the notice returns next visit */
    }
  };

  return (
    <Box role="note" sx={{ bgcolor: colors.surfaceContainerHigh, py: "20px" }}>
      <ConstrainedBody maxWidth={1100}>
        <Box
          sx={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "flex-start",
            gap: "10px",
          }}
        >
          <Typography
            sx={{ color: colors.onSurfaceVariant, whiteSpace: "pre-line" }}
          >
            <Typography component="span" sx={{ fontSize: 16, fontWeight: 500 }}>
              {t({
                id: "editingEventNotice",
                message: "You are editing an event. \n",
              })}
            </Typography>
            {t({
              id: "editingFutureInstancesNotice",
              message: "If you want to edit future instances, ",
            })}
            <Link
              component={RouterLink}
              to={paths
                .community(community.displayId)
                .template(event.templateId)}
              color="inherit"
              underline="always"
            >
              {t({ id: "editTheTemplate", message: "edit the template." })}
            </Link>
          </Typography>
          <IconButton
            aria-label={t({ id: "hideNotice", message: "Hide this notice" })}
            onClick={hide}
          >
            <CloseIcon color="primary" />
          </IconButton>
        </Box>
      </ConstrainedBody>
    </Box>
  );
}
