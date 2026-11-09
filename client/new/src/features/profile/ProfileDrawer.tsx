import CloseIcon from "@mui/icons-material/Close";
import Box from "@mui/material/Box";
import Drawer from "@mui/material/Drawer";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { Avatar } from "@/components/Avatar";
import { LoadingState } from "@/components/States";
import { roleLabel } from "@/utils/membership";
import { useCommunityScopeOrNull } from "@/scopes/CommunityScope";
import { useUser } from "@/queries/me";
import { useMembers } from "@/queries/communities";
import { colors, fontSizes } from "@/theme/tokens";

/**
 * Read-only profile drawer opened from any avatar: 160px picture, name, role in the current
 * community (when there is one) and the "about" text. Right-anchored, white, 20px padding.
 */
export function ProfileDrawer({
  userId,
  onClose,
}: {
  userId: string;
  onClose: () => void;
}) {
  const { data: user, isPending } = useUser(userId);
  const scope = useCommunityScopeOrNull();

  return (
    <Drawer
      anchor="right"
      open
      onClose={onClose}
      slotProps={{ paper: { sx: { width: "min(420px, 100vw)", px: "20px" } } }}
    >
      <Box sx={{ display: "flex", justifyContent: "flex-end", pt: "12px" }}>
        <IconButton aria-label="Close" onClick={onClose}>
          <CloseIcon />
        </IconButton>
      </Box>
      {isPending || !user ? (
        <LoadingState height={200} />
      ) : (
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            alignItems: "flex-start",
            gap: "20px",
            pb: 4,
          }}
        >
          <Avatar
            name={user.displayName}
            imageUrl={user.imageUrl}
            size={160}
            ring={false}
          />
          <Typography
            component="h2"
            sx={{
              fontSize: fontSizes["2xl"],
              fontWeight: 700,
              lineHeight: 1.1,
            }}
          >
            {user.displayName}
          </Typography>
          {scope && (
            <RoleRow userId={userId} communityId={scope.community.id} />
          )}
          {user.about && (
            <Typography
              sx={{
                fontSize: fontSizes.md,
                color: colors.onSurfaceVariant,
                lineHeight: 1.5,
              }}
            >
              {user.about}
            </Typography>
          )}
        </Box>
      )}
    </Drawer>
  );
}

function RoleRow({
  userId,
  communityId,
}: {
  userId: string;
  communityId: string;
}) {
  const { data: members } = useMembers(communityId);
  const status = members?.find((m) => m.user.id === userId)?.membership.status;
  if (!status) return null;
  return (
    <Typography sx={{ fontSize: fontSizes.md }}>{roleLabel(status)}</Typography>
  );
}
