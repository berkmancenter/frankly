import AssignmentOutlinedIcon from "@mui/icons-material/AssignmentOutlined";
import CalendarMonthRoundedIcon from "@mui/icons-material/CalendarMonthRounded";
import ForumOutlinedIcon from "@mui/icons-material/ForumOutlined";
import MenuIcon from "@mui/icons-material/Menu";
import SettingsOutlinedIcon from "@mui/icons-material/SettingsOutlined";
import Box from "@mui/material/Box";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { useState } from "react";
import { useLocation, useNavigate } from "react-router";
import { paths } from "@/app/paths";
import { ActionButton } from "@/components/ActionButton";
import { CommunityMembershipButton } from "@/components/CommunityMembershipButton";
import { ConstrainedBody } from "@/components/ConstrainedBody";
import { useIsMobile } from "@/utils/useResponsive";
import { useResources } from "@/queries/content";
import { useCommunityScopeOrNull } from "@/scopes/CommunityScope";
import { appSize, colors, fontSizes } from "@/theme/tokens";
import { AnnouncementsBell } from "./AnnouncementsBell";
import { CurrentCommunityIconOrLogo } from "./CurrentCommunityIconOrLogo";
import { OnboardingBanner, currentOnboardingStep } from "./OnboardingBanner";
import { ProfileMenu } from "./ProfileMenu";
import { SelectableNavigationIcon } from "./SelectableNavigationIcon";

function NavTextButton({
  title,
  onClick,
  selected,
}: {
  title: string;
  onClick: () => void;
  selected: boolean;
}) {
  return (
    <ActionButton type="text" onPress={onClick}>
      <Box
        sx={{
          borderBottom: selected ? "1.5px solid" : "1.5px solid transparent",
          borderColor: selected ? "primary.main" : "transparent",
        }}
      >
        <Typography
          component="div"
          sx={{ fontSize: fontSizes.md, fontWeight: 500, color: selected ? colors.onSurface : colors.onSurfaceVariant }}
        >
          {title}
        </Typography>
      </Box>
    </ActionButton>
  );
}

/**
 * The top bar. Everything about *where we are* is derived — from the enclosing
 * `CommunityScope` (null outside a community) and the URL — there is no nav-bar store.
 */
export function NavBar({ onMenuClick }: { onMenuClick: () => void }) {
  const scope = useCommunityScopeOrNull();
  const isMobile = useIsMobile();
  const navigate = useNavigate();
  const { pathname } = useLocation();
  const [onboardingOpen, setOnboardingOpen] = useState(true);

  const community = scope?.community;
  const permissions = scope?.permissions;
  const resources = useResources(community?.id);

  const onCommunityPage = !!community;
  const canViewLinks = permissions?.canViewCommunityLinks ?? false;
  const adminVisible = !!permissions?.canEditCommunity && onCommunityPage;
  const showResources =
    (resources.data?.length ?? 0) > 0 || !!permissions?.canEditCommunity;
  const discussionsEnabled =
    community?.settings.enableDiscussionThreads ?? false;
  const links = community ? paths.community(community.displayId) : null;

  const isAt = (p: string) => pathname === p;
  const showMembershipButton = !!community && !canViewLinks && !isMobile;

  const onboarding =
    community &&
    adminVisible &&
    community.isOnboardingOverviewEnabled &&
    isAt(links!.home) &&
    onboardingOpen &&
    currentOnboardingStep(community);

  return (
    <Box component="header">
      {onboarding && community && (
        <OnboardingBanner
          community={community}
          onDismiss={() => setOnboardingOpen(false)}
        />
      )}
      <Box
        sx={{
          bgcolor: colors.surfaceContainerLowest,
          display: "flex",
          justifyContent: "center",
        }}
      >
        <ConstrainedBody
          paddingLeft={20}
          paddingRight={10}
          sx={{ width: "100%" }}
        >
          <Box
            sx={{
              height: appSize.navBarHeight,
              display: "flex",
              alignItems: "center",
            }}
          >
            <CurrentCommunityIconOrLogo />

            {community && links && !isMobile && (
              <>
                <Box
                  sx={{
                    flex: showMembershipButton ? "0 1 auto" : 1,
                    display: "flex",
                    minWidth: 0,
                  }}
                >
                  <ActionButton
                    type="text"
                    contentAlign="start"
                    maxTextWidth={180}
                    maxLines={2}
                    text={community.name}
                    sx={{ fontSize: fontSizes.md, fontWeight: 500, textAlign: "left" }}
                    onPress={() => navigate(links.home)}
                  />
                </Box>
                {showMembershipButton && (
                  <Box sx={{ flex: 1, ml: "16px" }}>
                    <CommunityMembershipButton community={community} />
                  </Box>
                )}
              </>
            )}

            {community && links && !isMobile && (
              <Box sx={{ display: "flex", alignItems: "center" }}>
                <NavTextButton
                  title="Events"
                  selected={isAt(links.events)}
                  onClick={() => navigate(links.events)}
                />
                {discussionsEnabled && (
                  <NavTextButton
                    title="Posts"
                    selected={isAt(links.posts)}
                    onClick={() => navigate(links.posts)}
                  />
                )}
                {showResources && (
                  <NavTextButton
                    title="Resources"
                    selected={isAt(links.resources)}
                    onClick={() => navigate(links.resources)}
                  />
                )}
                <NavTextButton
                  title="Templates"
                  selected={isAt(links.templates)}
                  onClick={() => navigate(links.templates)}
                />
              </Box>
            )}
            {!community && <Box sx={{ flex: 1 }} />}

            {community && canViewLinks && !isMobile && <AnnouncementsBell />}

            {!isMobile && <ProfileMenu />}

            {isMobile && community && links && (
              <Box
                sx={{
                  display: "flex",
                  alignItems: "center",
                  ml: "20px",
                  gap: "20px",
                }}
              >
                {!canViewLinks ? (
                  <CommunityMembershipButton community={community} />
                ) : (
                  <>
                    <SelectableNavigationIcon
                      label="Events"
                      selected={isAt(links.events)}
                      icon={<CalendarMonthRoundedIcon sx={{ fontSize: 32 }} />}
                      onClick={() => navigate(links.events)}
                    />
                    {discussionsEnabled && (
                      <SelectableNavigationIcon
                        label="Posts"
                        selected={isAt(links.posts)}
                        icon={<ForumOutlinedIcon sx={{ fontSize: 32 }} />}
                        onClick={() => navigate(links.posts)}
                      />
                    )}
                    {showResources && (
                      <SelectableNavigationIcon
                        label="Resources"
                        selected={isAt(links.resources)}
                        icon={<AssignmentOutlinedIcon sx={{ fontSize: 32 }} />}
                        onClick={() => navigate(links.resources)}
                      />
                    )}
                  </>
                )}
              </Box>
            )}
            {isMobile && <Box sx={{ flex: 1 }} />}

            {adminVisible && links && (
              <SelectableNavigationIcon
                label="Admin"
                selected={pathname.startsWith(`${links.home}/admin`)}
                icon={<SettingsOutlinedIcon sx={{ fontSize: 30 }} />}
                onClick={() => navigate(links.admin())}
              />
            )}
            <IconButton
              aria-label="Show sidebar"
              onClick={onMenuClick}
              sx={{ ml: "8px", color: "secondary.main" }}
            >
              <MenuIcon sx={{ fontSize: 34 }} />
            </IconButton>
          </Box>
        </ConstrainedBody>
      </Box>
      <Box sx={{ height: "1px", bgcolor: colors.outline }} />
    </Box>
  );
}
