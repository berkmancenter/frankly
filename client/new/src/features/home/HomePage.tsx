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
import { SignInCard } from "@/features/auth/SignInCard";
import { useIsRegistered } from "@/features/auth/useAuthSession";
import { CreateCommunityButton } from "@/features/community/CreateCommunity";
import { useMyCommunities } from "@/queries/communities";
import { colors, fontSizes } from "@/theme/tokens";
import { useIsMobile } from "@/utils/useResponsive";

/**
 * The page at "/". A visitor without an account gets the sign-in form:
 * a signed-in user gets their communities. Signing in needs no explicit
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

/**
 * Placeholder for the communities list: a plain list of the user's communities, or a note that
 * there are none.
 */
function MyCommunities() {
  const communities = useMyCommunities();
  const isMobile = useIsMobile();

  return (
    <Box sx={{ maxWidth: 600, mx: "auto", px: "20px", py: "40px" }}>
      <Box sx={{ display: "flex", alignItems: "center" }}>
        <Typography
          component="h1"
          sx={{ fontSize: fontSizes["3xl"], fontWeight: 700 }}
        >
          <Trans id="myCommunities">My Communities</Trans>
        </Typography>
        <Box sx={{ flex: 1 }} />
        <CreateCommunityButton showLabel={!isMobile} />
      </Box>
      <Typography sx={{ mt: "8px", color: colors.onSurfaceVariant }}>
        <Trans>
          Placeholder: the home page is not built yet. This is a plain list of
          your communities.
        </Trans>
      </Typography>
      {communities.isPending ? (
        <LoadingState height="40vh" />
      ) : communities.isError ? (
        <ErrorState
          message={t({
            id: "errorLoadingCommunitiesMessage",
            message:
              "Something went wrong loading communities. Please refresh.",
          })}
        />
      ) : communities.data.length === 0 ? (
        <Typography
          sx={{
            py: "40px",
            textAlign: "center",
            color: colors.onSurfaceVariant,
          }}
        >
          <Trans>You don't belong to any communities</Trans>
        </Typography>
      ) : (
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
      )}
    </Box>
  );
}
