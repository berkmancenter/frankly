import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import { t } from "@lingui/core/macro";
import type { BackendFailure, BackendFailureKind } from "@/api/backendFailure";
import { useFirebaseEmulators } from "@/api/firebase";
import { ActionButton } from "@/components/ActionButton";
import { colors, fontSizes } from "@/theme/tokens";

function copy(kind: BackendFailureKind): { title: string; body: string } {
  switch (kind) {
    case "config":
      return {
        title: t({ id: "backendMisconfiguredTitle", message: "The app can't connect to its backend" }),
        body: t({
          id: "backendMisconfiguredBody",
          message:
            "The backend looks misconfigured (a project or API key that doesn't exist, or a disabled service). If you run this site, check its Firebase settings.",
        }),
      };
    case "network":
      return {
        title: t({ id: "backendUnreachableTitle", message: "We can't reach the server" }),
        body: t({
          id: "backendUnreachableBody",
          message: "Check your internet connection and try again.",
        }),
      };
    case "service":
      return {
        title: t({ id: "backendDownTitle", message: "The service is unavailable" }),
        body: t({
          id: "backendDownBody",
          message: "Our backend isn't responding right now. Please try again in a few minutes.",
        }),
      };
    default:
      return {
        title: t({ id: "backendUnknownTitle", message: "Something went wrong" }),
        body: t({
          id: "backendUnknownBody",
          message: "Could not load your session. Please try again.",
        }),
      };
  }
}

/**
 * Full-page explanation for when the app cannot start because of the backend: what kind of
 * problem it is, a technical details line, and a way to retry. Reloading is the retry, since a
 * fixed configuration is only picked up by a fresh load.
 */
export function BackendUnavailable({
  failure,
  onRetry = () => window.location.reload(),
}: {
  failure: BackendFailure;
  onRetry?: () => void;
}) {
  const { title, body } = copy(failure.kind);
  const emulators = useFirebaseEmulators();
  return (
    <Box
      role="alert"
      sx={{
        minHeight: "100dvh",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: "16px",
        p: "24px",
        textAlign: "center",
      }}
    >
      <Typography component="h1" sx={{ fontSize: fontSizes["2xl"], color: colors.onSurface }}>
        {title}
      </Typography>
      <Typography sx={{ maxWidth: 480, fontSize: fontSizes.md, color: colors.onSurfaceVariant }}>
        {body}
      </Typography>
      {emulators && failure.kind !== "unknown" && (
        <Typography sx={{ maxWidth: 480, color: colors.onSurfaceVariant }}>
          {t({
            id: "backendEmulatorsHint",
            message: "This build uses the local Firebase emulators. Are they running?",
          })}
        </Typography>
      )}
      <ActionButton
        text={t({ id: "tryAgain", message: "Try again" })}
        color={colors.primary}
        textColor={colors.onPrimary}
        onPress={onRetry}
      />
      {(failure.code !== "unknown" || failure.message) && (
        <Typography
          variant="body2"
          component="code"
          sx={{
            maxWidth: 560,
            color: colors.onSurfaceVariant,
            wordBreak: "break-word",
          }}
        >
          {[failure.code !== "unknown" ? failure.code : "", failure.message].filter(Boolean).join(": ")}
        </Typography>
      )}
    </Box>
  );
}
