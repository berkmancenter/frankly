import ArrowForwardIosIcon from "@mui/icons-material/ArrowForwardIos";
import CloseIcon from "@mui/icons-material/Close";
import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import IconButton from "@mui/material/IconButton";
import LinearProgress from "@mui/material/LinearProgress";
import Typography from "@mui/material/Typography";
import { useNavigate } from "react-router";
import type { Community, OnboardingStep } from "@/api/types";
import { paths } from "@/app/paths";
import { ConstrainedBody } from "@/components/ConstrainedBody";
import { useIsMobile } from "@/utils/useResponsive";
import { useCreateEventDialog } from "@/features/events/CreateEventDialog";
import { colors } from "@/theme/tokens";

/** Order and copy of the admin onboarding checklist (`OnboardingStepExtension`). */
export const ONBOARDING_STEPS: OnboardingStep[] = [
  "brandSpace",
  "createTemplate",
  "hostEvent",
  "inviteSomeone",
];

const COPY: Record<
  OnboardingStep,
  { icon: string; title: string; section: string }
> = {
  brandSpace: {
    icon: "emoji-sparkle.png",
    title: "Looking good",
    section: "Brand your space",
  },
  createTemplate: {
    icon: "emoji-notepad.png",
    title: "Looking good",
    section: "Create a template",
  },
  hostEvent: {
    icon: "emoji-megaphone.png",
    title: "Get people talking",
    section: "Schedule an event",
  },
  inviteSomeone: {
    icon: "emoji-calendar.png",
    title: "Get it on the books",
    section: "Invite your people",
  },
};

export function currentOnboardingStep(
  community: Community,
): OnboardingStep | null {
  return (
    ONBOARDING_STEPS.find((s) => !community.onboardingSteps.includes(s)) ?? null
  );
}

/**
 * Admin-only banner under the nav bar on the community home: "what to do next", a progress
 * bar and a dismiss button.
 */
export function OnboardingBanner({
  community,
  onDismiss,
}: {
  community: Community;
  onDismiss: () => void;
}) {
  const step = currentOnboardingStep(community);
  const isMobile = useIsMobile();
  const navigate = useNavigate();
  const createEvent = useCreateEventDialog();
  if (!step) return null;

  const done = community.onboardingSteps.filter((s) =>
    ONBOARDING_STEPS.includes(s),
  ).length;
  const total = ONBOARDING_STEPS.length;
  const copy = COPY[step];

  // Creating templates and branding the space are not migrated: these hand off to Flutter.
  const act = () => {
    const links = paths.community(community.displayId);
    if (step === "createTemplate") navigate(links.templates);
    else if (step === "hostEvent") createEvent.open();
    else navigate(links.admin());
  };

  const progress = (
    <Box sx={{ flex: 1, minWidth: 80, maxWidth: isMobile ? undefined : 300 }}>
      <LinearProgress
        variant="determinate"
        value={(done / total) * 100}
        aria-label="Onboarding progress"
        sx={{
          bgcolor: "primary.contrastText",
          "& .MuiLinearProgress-bar": { bgcolor: colors.primaryFixedDim },
          height: 6,
          borderRadius: 3,
        }}
      />
    </Box>
  );

  const label = (
    <ButtonBase
      onClick={act}
      sx={{ color: "primary.contrastText", textAlign: "left", gap: "5px" }}
    >
      <img src={`/media/${copy.icon}`} alt="" width={16} height={16} />
      <Typography
        sx={{ fontSize: 16, fontWeight: 600, color: "inherit" }}
      >
        {copy.title}
      </Typography>
      <Typography
        sx={{ fontSize: 16, fontWeight: 600, color: "inherit", ml: "5px" }}
      >
        {copy.section}
      </Typography>
      <ArrowForwardIosIcon sx={{ fontSize: 12 }} />
    </ButtonBase>
  );

  return (
    <Box
      role="region"
      aria-label="Community onboarding"
      sx={{ bgcolor: colors.primaryContainer, py: "5px", px: "10px" }}
    >
      {isMobile ? (
        <Box>
          <Box sx={{ display: "flex", alignItems: "center", gap: "10px" }}>
            {progress}
            <Typography sx={{ color: "primary.contrastText", fontSize: 16 }}>
              {done}/{total}
            </Typography>
            <IconButton
              size="small"
              aria-label="Dismiss onboarding"
              onClick={onDismiss}
              sx={{ color: "primary.contrastText" }}
            >
              <CloseIcon fontSize="small" />
            </IconButton>
          </Box>
          {label}
        </Box>
      ) : (
        <ConstrainedBody maxWidth={1100} paddingLeft={0} paddingRight={0}>
          <Box sx={{ display: "flex", alignItems: "center" }}>
            {label}
            <Box sx={{ flex: 1 }} />
            {progress}
            <Typography
              sx={{ color: "primary.contrastText", fontSize: 16, ml: "10px" }}
            >
              {done}/{total}
            </Typography>
            <IconButton
              aria-label="Dismiss onboarding"
              onClick={onDismiss}
              sx={{ color: "primary.contrastText", ml: "12px" }}
            >
              <CloseIcon />
            </IconButton>
          </Box>
        </ConstrainedBody>
      )}
      {createEvent.dialog}
    </Box>
  );
}
