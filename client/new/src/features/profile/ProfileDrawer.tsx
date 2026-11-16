import CloseIcon from "@mui/icons-material/Close";
import Box from "@mui/material/Box";
import EmailIcon from "@mui/icons-material/EmailOutlined";
import FacebookIcon from "@mui/icons-material/Facebook";
import InstagramIcon from "@mui/icons-material/Instagram";
import LinkedInIcon from "@mui/icons-material/LinkedIn";
import TwitterIcon from "@mui/icons-material/Twitter";
import Drawer from "@mui/material/Drawer";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { Avatar } from "@/components/Avatar";
import { ErrorState, LoadingState } from "@/components/States";
import { isAdmin, roleLabel } from "@/utils/membership";
import { useCommunityScopeOrNull } from "@/scopes/CommunityScope";
import type { SocialPlatform } from "@/api/types";
import { useMe, useUser } from "@/queries/me";
import { useUserEmail, useUserTags } from "@/queries/tags";
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
  const { t } = useLingui();
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
        <IconButton aria-label={t`Close`} onClick={onClose}>
          <CloseIcon />
        </IconButton>
      </Box>
      {isPending ? (
        <LoadingState height={200} />
      ) : !user ? (
        <ErrorState message={t`Could not load this profile.`} />
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
          <ContactInfo userId={userId} />
          {user.socialLinks && user.socialLinks.length > 0 && (
            <Box sx={{ display: "flex", gap: "4px" }}>
              {user.socialLinks.flatMap(({ platform, url }) => {
                const href = webUrl(url);
                const Icon = SOCIAL_ICONS[platform];
                return href
                  ? [
                      <IconButton
                        key={platform}
                        component="a"
                        href={href}
                        target="_blank"
                        rel="noopener noreferrer"
                        aria-label={platform}
                      >
                        <Icon />
                      </IconButton>,
                    ]
                  : [];
              })}
            </Box>
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
          <ProfileTags userId={userId} />
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
  const { i18n } = useLingui();
  const { data: members } = useMembers(communityId);
  const status = members?.find((m) => m.user.id === userId)?.membership.status;
  if (!status) return null;
  return (
    <Typography sx={{ fontSize: fontSizes.md }}>{i18n._(roleLabel(status))}</Typography>
  );
}

// Platform ids stored in Firestore double as the icon buttons' accessible names.
const SOCIAL_ICONS: Record<SocialPlatform, typeof InstagramIcon> = {
  instagram: InstagramIcon,
  twitter: TwitterIcon,
  facebook: FacebookIcon,
  linkedin: LinkedInIcon,
};

// A user-typed link made safe to open: http(s) only, and a bare "example.com" gets https.
function webUrl(raw: string): string | undefined {
  const text = raw.trim();
  if (!text) return undefined;
  try {
    const url = new URL(/^[a-z][a-z\d+.-]*:/i.test(text) ? text : `https://${text}`);
    return url.protocol === "https:" || url.protocol === "http:" ? url.href : undefined;
  } catch {
    return undefined;
  }
}

// The email: only the user themself and the community's admins may see it (the server enforces this too).
function ContactInfo({ userId }: { userId: string }) {
  const scope = useCommunityScopeOrNull();
  const me = useMe().data?.user.id;
  const allowed = !!me && (me === userId || (!!scope && isAdmin(scope.status)));
  const { data: email } = useUserEmail(userId, scope?.community.id, allowed);
  if (!email) return null;
  return (
    <Box sx={{ display: "flex", alignItems: "center", gap: "8px", wordBreak: "break-all" }}>
      <EmailIcon aria-hidden fontSize="small" />
      <Typography component="a" href={`mailto:${email}`} sx={{ fontSize: fontSizes.md, color: "inherit" }}>
        {email}
      </Typography>
    </Box>
  );
}

function ProfileTags({ userId }: { userId: string }) {
  const { t } = useLingui();
  const { data: tags } = useUserTags(userId);
  if (!tags?.length) return null;
  return (
    <Box>
      <Typography component="h3" sx={{ fontSize: fontSizes.lg, fontWeight: 700, color: "primary.main", mb: "10px" }}>
        {t({ id: "tags", message: "Tags" })}
      </Typography>
      <Typography>{tags.map((tag) => `#${tag.title}`).join(" ")}</Typography>
    </Box>
  );
}
