import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import Typography from "@mui/material/Typography";
import { t } from "@lingui/core/macro";
import { Trans } from "@lingui/react/macro";
import { Link } from "react-router";
import { paths } from "@/app/paths";
import { StandalonePage } from "@/app/layouts/StandalonePage";
import { CommunityCircleIcon } from "@/components/CommunityCircleIcon";
import { ErrorState, LoadingState } from "@/components/States";
import { SignInForm } from "@/features/auth/SignInForm";
import { useIsRegistered } from "@/features/auth/useAuthSession";
import { useMyCommunities } from "@/queries/communities";
import { colors, fontSizes } from "@/theme/tokens";

/**
 * The page at "/". A visitor without an account gets the sign-in form (sign-up first, like
 * Flutter's home page); a signed-in user gets their communities. Signing in needs no explicit
 * navigation: the session changes and this page renders the other branch.
 */
export function HomePage() {
  const registered = useIsRegistered();
  return (
    <StandalonePage>
      {registered ? <MyCommunities /> : <SignInCard />}
    </StandalonePage>
  );
}

function SignInCard() {
  return (
    <Box
      sx={{ display: "flex", justifyContent: "center", px: "20px", py: "40px" }}
    >
      <Box
        sx={{
          width: "100%",
          maxWidth: 400,
          p: "40px",
          borderRadius: "20px",
          bgcolor: colors.transparent,
        }}
      >
        <SignInForm />
      </Box>
    </Box>
  );
}

/**
 * Placeholder for the communities list: a plain list of the user's communities, or a note that
 * there are none.
 */
function MyCommunities() {
  const communities = useMyCommunities();

  if (communities.isPending) return <LoadingState height="60vh" />;
  if (communities.isError) {
    return (
      <ErrorState
        message={t({
          id: "errorLoadingCommunities",
          message: t({
            id: "errorLoadingCommunitiesMessage",
            message:
              "Something went wrong loading communities. Please refresh.",
          }),
        })}
      />
    );
  }
  if (communities.data.length === 0) {
    return (
      <Typography
        sx={{
          py: "40px",
          px: "20px",
          textAlign: "center",
          color: colors.onSurfaceVariant,
        }}
      >
        You don't belong to any communities
      </Typography>
    );
  }

  return (
    <Box sx={{ maxWidth: 600, mx: "auto", px: "20px", py: "40px" }}>
      <Typography
        component="h1"
        sx={{ fontSize: fontSizes["3xl"], fontWeight: 700 }}
      >
        <Trans id="myCommunities">My Communities</Trans>
      </Typography>
      <Typography sx={{ mt: "8px", color: colors.onSurfaceVariant }}>
        Placeholder: the home page is not built yet. This is a plain list of
        your communities.
      </Typography>
      <Box
        component="ul"
        sx={{
          listStyle: "none",
          p: 0,
          mt: "24px",
          display: "grid",
          gap: "8px",
        }}
      >
        {communities.data.map((community) => (
          <li key={community.id}>
            <ButtonBase
              component={Link}
              to={paths.community(community.displayId).home}
              sx={{
                width: "100%",
                gap: "16px",
                p: "12px",
                justifyContent: "flex-start",
                textAlign: "left",
                borderRadius: "12px",
                bgcolor: colors.surfaceContainerLowest,
              }}
            >
              <CommunityCircleIcon community={community} size={48} />
              <Box sx={{ minWidth: 0 }}>
                <Typography sx={{ fontSize: fontSizes.md, fontWeight: 500 }}>
                  {community.name}
                </Typography>
                {community.tagLine && (
                  <Typography sx={{ color: colors.onSurfaceVariant }}>
                    {community.tagLine}
                  </Typography>
                )}
              </Box>
            </ButtonBase>
          </li>
        ))}
      </Box>
    </Box>
  );
}
