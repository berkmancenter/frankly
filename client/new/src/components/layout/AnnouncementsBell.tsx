import DeleteIcon from "@mui/icons-material/Delete";
import NotificationsNoneRoundedIcon from "@mui/icons-material/NotificationsNoneRounded";
import Box from "@mui/material/Box";
import IconButton from "@mui/material/IconButton";
import Popover from "@mui/material/Popover";
import Typography from "@mui/material/Typography";
import { t } from "@lingui/core/macro";
import { Trans } from "@lingui/react/macro";
import { useState } from "react";
import { ActionButton } from "@/components/ActionButton";
import { AppDialog } from "@/components/AppDialog";
import { useConfirm } from "@/components/ConfirmDialog";
import { ThickOutlineButton } from "@/components/ThickOutlineButton";
import { useToast } from "@/components/Toast";
import { formatLongStamp } from "@/utils/format";
import { isBlank } from "@/utils/strings";
import {
  useAnnouncements,
  useCreateAnnouncement,
  useRemoveAnnouncement,
} from "@/queries/content";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { TextField } from "@mui/material";
import { colors, fontSizes } from "@/theme/tokens";

/** `AnnouncementsIcon`: bell in the nav bar; opens a popover with the community's announcements. */
export function AnnouncementsBell() {
  const { community, permissions } = useCommunityScope();
  const [anchor, setAnchor] = useState<HTMLElement | null>(null);
  const [createOpen, setCreateOpen] = useState(false);
  const {
    data: announcements,
    isError,
    isPending,
  } = useAnnouncements(community.id);
  const remove = useRemoveAnnouncement(community.id);
  const { confirm, dialog } = useConfirm();
  const toast = useToast();

  return (
    <Box sx={{ width: 50, display: "flex", justifyContent: "center" }}>
      <IconButton
        aria-label={t`Show Announcements Button`}
        onClick={(e) => setAnchor(e.currentTarget)}
        sx={{ color: anchor ? colors.onSurface : colors.onSurfaceVariant }}
      >
        <NotificationsNoneRoundedIcon sx={{ fontSize: 30 }} />
      </IconButton>
      <Popover
        open={!!anchor}
        anchorEl={anchor}
        onClose={() => setAnchor(null)}
        anchorOrigin={{ vertical: "bottom", horizontal: "center" }}
        transformOrigin={{ vertical: "top", horizontal: "center" }}
        slotProps={{
          paper: {
            sx: {
              width: 260,
              p: "12px",
              borderRadius: "8px",
              bgcolor: colors.surfaceContainerLowest,
              maxHeight: announcements?.length ? 400 : 200,
              boxShadow: "0 4px 12px rgba(0,0,0,0.25)",
            },
          },
        }}
      >
        <Typography component="div" sx={{ fontSize: fontSizes.sm, fontWeight: 500 }}><Trans>Announcements</Trans></Typography>
        {permissions.canEditCommunity && (
          <Box sx={{ mt: "16px" }}>
            <ThickOutlineButton
              text={t`New Announcement`}
              onPress={() => {
                setAnchor(null);
                setCreateOpen(true);
              }}
            />
          </Box>
        )}
        <Box sx={{ mt: "30px" }}>
          {isError ? (
            <Typography>
              <Trans>There was an error while loading Announcements</Trans>
            </Typography>
          ) : isPending ? null : announcements.length === 0 ? (
            <Typography><Trans>No announcements yet.</Trans></Typography>
          ) : (
            announcements.map((a) => (
              <Box key={a.id} sx={{ mb: "25px" }}>
                <Box
                  sx={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "space-between",
                  }}
                >
                  <Typography component="div" sx={{ fontSize: fontSizes.sm, fontWeight: 500 }}>
                    {/* Fallback title shown when an announcement was saved without one. */}
                    {a.title || t`Announcement`}
                  </Typography>
                  {permissions.canEditCommunity && (
                    <IconButton
                      size="small"
                      aria-label={t`Delete announcement`}
                      onClick={async () => {
                        if (
                          await confirm({
                            title: t`Are you sure you want to delete this announcement?`,
                            cancelText: t`No`,
                            confirmText: t`Yes`,
                          })
                        ) {
                          await remove.mutateAsync(a.id);
                          toast.show(t`Announcement deleted`);
                        }
                      }}
                    >
                      <DeleteIcon
                        sx={{ fontSize: 20, color: "primary.main" }}
                      />
                    </IconButton>
                  )}
                </Box>
                <Typography
                  component="div"
                  sx={{
                    fontSize: 11,
                    fontStyle: "italic",
                    color: "primary.main",
                    pt: "2px",
                    pb: "8px",
                  }}
                >
                  {a.createdDate && formatLongStamp(new Date(a.createdDate))}
                </Typography>
                <Typography
                  sx={{ whiteSpace: "pre-wrap" }}
                >
                  {a.message}
                </Typography>
              </Box>
            ))
          )}
        </Box>
      </Popover>
      {dialog}
      {createOpen && (
        <CreateAnnouncementDialog
          communityId={community.id}
          onClose={() => setCreateOpen(false)}
        />
      )}
    </Box>
  );
}

function CreateAnnouncementDialog({
  communityId,
  onClose,
}: {
  communityId: string;
  onClose: () => void;
}) {
  const create = useCreateAnnouncement(communityId);
  const toast = useToast();
  const [title, setTitle] = useState("");
  const [message, setMessage] = useState("");
  return (
    <AppDialog open onClose={onClose} maxWidth={600}>
      <Box
        sx={{
          pt: "20px",
          display: "flex",
          flexDirection: "column",
          gap: "12px",
        }}
      >
        <Typography sx={{ fontSize: 26, fontWeight: 700 }}>
          <Trans>Create New Announcement</Trans>
        </Typography>
        <TextField
          label={t`Enter a title`}
          value={title}
          onChange={(e) => setTitle(e.target.value)}
        />
        <TextField
          label={t`Enter a message`}
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          multiline
          minRows={4}
          maxRows={8}
        />
        <Box sx={{ display: "flex", justifyContent: "flex-end", mt: "3px" }}>
          <ActionButton
            text={t`Create`}
            disabled={isBlank(message)}
            onPress={async () => {
              try {
                await create.mutateAsync({
                  title: title.trim() || undefined,
                  message: message.trim(),
                });
                toast.success(t`Announcement created`);
                onClose();
              } catch {
                toast.error(t`Something went wrong. Please try again.`);
              }
            }}
          />
        </Box>
      </Box>
    </AppDialog>
  );
}
