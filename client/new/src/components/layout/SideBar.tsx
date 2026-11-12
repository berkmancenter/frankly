import ArrowForwardIosIcon from "@mui/icons-material/ArrowForwardIos";
import CloseIcon from "@mui/icons-material/Close";
import Box from "@mui/material/Box";
import Collapse from "@mui/material/Collapse";
import Divider from "@mui/material/Divider";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { useState } from "react";
import { useLocation, useNavigate } from "react-router";
import type { Community } from "@/api/types";
import { paths } from "@/app/paths";
import { ActionButton } from "@/components/ActionButton";
import { CommunityCircleIcon } from "@/components/CommunityCircleIcon";
import { CommunityMembershipButton } from "@/components/CommunityMembershipButton";
import { LoadingState } from "@/components/States";
import { computeCommunityPermissions } from "@/utils/permissions";
import {
  CreateCommunityButton,
  useCanCreateCommunity,
} from "@/features/community/CreateCommunity";
import { useMyCommunities, useUnfollowCommunity } from "@/queries/communities";
import { useResources } from "@/queries/content";
import { useMembership } from "@/queries/me";
import { useCommunityScopeOrNull } from "@/scopes/CommunityScope";
import { appSize, colors, fontSizes } from "@/theme/tokens";
import { useConfirm } from "../ConfirmDialog";

const HELP_URL = "https://berkmancenter.github.io/frankly";

function SidebarLink({
  label,
  onClick,
}: {
  label: string;
  onClick: () => void;
}) {
  return (
    <ActionButton
      type="text"
      expand
      contentAlign="start"
      onPress={onClick}
      sx={{ px: "16px" }}
    >
      <Typography sx={{ fontSize: fontSizes.md }}>{label}</Typography>
    </ActionButton>
  );
}

/** One community in the drawer: icon + name + (collapsible) links. */
function SidebarCommunityItem({
  community,
  collapsible,
  openByDefault,
  onNavigate,
}: {
  community: Community;
  collapsible: boolean;
  openByDefault: boolean;
  onNavigate: () => void;
}) {
  const [open, setOpen] = useState(openByDefault || !collapsible);
  const navigate = useNavigate();
  const membership = useMembership(community.id);
  const resources = useResources(community.id);
  const unfollow = useUnfollowCommunity();
  const { confirm, dialog } = useConfirm();
  const status = membership?.status ?? "nonmember";
  const permissions = computeCommunityPermissions(community, status, true);
  const links = paths.community(community.displayId);
  const go = (to: string) => {
    onNavigate();
    navigate(to);
  };
  const showResources =
    (resources.data?.length ?? 0) > 0 || permissions.canEditCommunity;

  return (
    <Box>
      <Box sx={{ display: "flex", alignItems: "center", gap: "8px" }}>
        <CommunityCircleIcon community={community} size={42} bordered />
        <ActionButton
          type="text"
          contentAlign="start"
          maxTextWidth={200}
          text={community.name || "Unnamed Community"}
          minWidth={0}
          sx={{
            py: "12px",
            px: "6px",
            fontSize: fontSizes.md,
            fontWeight: 500,
          }}
          onPress={() => go(links.home)}
        />
        <Box sx={{ flex: 1 }} />
        {collapsible && (
          <IconButton
            aria-label={open ? "Collapse" : "Expand"}
            onClick={() => setOpen((o) => !o)}
            sx={{ p: "8px" }}
          >
            <ArrowForwardIosIcon
              sx={{
                fontSize: 16,
                transform: `rotate(${open ? 270 : 90}deg)`,
                transition: "transform .2s",
              }}
            />
          </IconButton>
        )}
      </Box>
      <Collapse in={open} unmountOnExit>
        {permissions.canViewCommunityLinks ? (
          <Box sx={{ pt: "12px", display: "flex", flexDirection: "column" }}>
            <SidebarLink label="Events" onClick={() => go(links.events)} />
            {community.settings.enableDiscussionThreads && (
              <SidebarLink label="Posts" onClick={() => go(links.posts)} />
            )}
            {showResources && (
              <SidebarLink
                label="Resources"
                onClick={() => go(links.resources)}
              />
            )}
            <SidebarLink
              label="Templates"
              onClick={() => go(links.templates)}
            />
            {!permissions.canEditCommunity && (
              <SidebarLink
                label="Unfollow"
                onClick={async () => {
                  if (
                    await confirm({
                      title: `Unfollow ${community.name}?`,
                      mainText:
                        "You will stop receiving updates and lose access to its events.",
                      cancelText: "Cancel",
                      confirmText: "Unfollow",
                    })
                  ) {
                    await unfollow.mutateAsync(community.id);
                  }
                }}
              />
            )}
            {permissions.canEditCommunity && (
              <SidebarLink label="Admin" onClick={() => go(links.admin())} />
            )}
          </Box>
        ) : (
          <Box sx={{ py: "8px" }}>
            <CommunityMembershipButton community={community} minWidth={315} />
          </Box>
        )}
      </Collapse>
      {dialog}
    </Box>
  );
}

/** The end drawer: the user's communities on top, global links below. */
export function SideBar({ onClose }: { onClose: () => void }) {
  const canCreate = useCanCreateCommunity();
  const mine = useMyCommunities();
  const scope = useCommunityScopeOrNull();
  const navigate = useNavigate();
  const { pathname } = useLocation();

  const current = scope?.community;
  const communities = [
    ...(current ? [current] : []),
    ...(mine.data ?? []).filter((c) => c.id !== current?.id),
  ];
  const onCommunityRoute = pathname.startsWith("/space/");

  const openExternal = (url: string) =>
    window.open(url, "_blank", "noopener,noreferrer");

  return (
    <Box
      sx={{
        width: appSize.sidebarWidth,
        maxWidth: "100vw",
        bgcolor: colors.surfaceContainerLowest,
        display: "flex",
        flexDirection: "column",
        height: "100%",
        overflowY: "auto",
      }}
    >
      <Box
        sx={{
          display: "flex",
          justifyContent: "flex-end",
          pt: "26px",
          pr: "26px",
        }}
      >
        <IconButton aria-label="Close" onClick={onClose}>
          <CloseIcon sx={{ fontSize: 34, color: "secondary.main" }} />
        </IconButton>
      </Box>

      <Box sx={{ flex: "1 0 auto", p: "20px" }}>
        {mine.isPending && !current ? (
          <LoadingState height={120} />
        ) : (
          <>
            {communities.map((community, index) => (
              <Box key={community.id}>
                {index > 0 && <Divider sx={{ my: "8px" }} />}
                <SidebarCommunityItem
                  community={community}
                  collapsible={communities.length > 1}
                  openByDefault={index === 0 && onCommunityRoute}
                  onNavigate={onClose}
                />
              </Box>
            ))}
            {canCreate && (
              <>
                {communities.length > 0 && <Divider sx={{ my: "8px" }} />}
                {/* The dialog opens over the drawer; the drawer closes once it is done. */}
                <CreateCommunityButton onDone={onClose} />
              </>
            )}
          </>
        )}
      </Box>

      <Box
        sx={{ bgcolor: colors.surface, p: "20px", pt: "32px", flexShrink: 0 }}
      >
        <ActionButton
          type="text"
          contentAlign="start"
          onPress={() => {
            onClose();
            navigate(paths.home);
          }}
          icon={
            <img
              src="/media/logo-icon.png"
              alt=""
              width={20}
              height={20}
              style={{ marginLeft: 4, marginRight: 6 }}
            />
          }
        >
          Frankly Home
        </ActionButton>
        <ActionButton
          type="text"
          contentAlign="start"
          onPress={() => openExternal(HELP_URL)}
        >
          Help Center
        </ActionButton>
        <ActionButton
          type="text"
          contentAlign="start"
          onPress={() => openExternal(HELP_URL)}
        >
          About Frankly
        </ActionButton>
        <ActionButton
          type="text"
          contentAlign="start"
          onPress={() => openExternal(HELP_URL)}
        >
          Privacy Policy
        </ActionButton>
        <Typography
          component="div"
          sx={{
            fontSize: fontSizes.xs,
            fontWeight: 500,
            color: colors.onSurfaceVariant,
            px: "8px",
            py: "24px",
            whiteSpace: "pre-line",
          }}
        >
          {`Open-source deliberation software (AGPL-3.0).\n© ${new Date().getFullYear()} Frankly contributors`}
        </Typography>
        <Typography
          component="div"
          sx={{
            fontSize: fontSizes.xs,
            fontWeight: 500,
            color: colors.onSurfaceVariant,
            px: "8px",
            textAlign: "right",
          }}
        >
          v3.0.0
        </Typography>
      </Box>
    </Box>
  );
}
