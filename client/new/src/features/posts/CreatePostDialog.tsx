import AttachFileRoundedIcon from "@mui/icons-material/AttachFileRounded";
import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import Dialog from "@mui/material/Dialog";
import Divider from "@mui/material/Divider";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { i18n } from "@lingui/core";
import { t } from "@lingui/core/macro";
import { Trans } from "@lingui/react/macro";
import { useState } from "react";
import type { DiscussionThread } from "@/api/types";
import { ActionButton } from "@/components/ActionButton";
import { AppDialog } from "@/components/AppDialog";
import { Avatar } from "@/components/Avatar";
import { useToast } from "@/components/Toast";
import { Upload } from "@/components/Upload";
import { isBlank } from "@/utils/strings";
import { useIsMobile } from "@/utils/useResponsive";
import { useCreateThread, useUpdateThread } from "@/queries/threads";
import { useCurrentUser } from "@/queries/me";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { EMOTIONS } from "./EmotionSection";
import { colors } from "@/theme/tokens";

const EMOJI_CHARS = ["👍", "❤️", "💯", "❗", "➕", "😂", "😍"];

/** Create / edit post: avatar + ✕, a growing text area, an image attachment, emoji shortcuts and "Post". */
export function CreatePostDialog({
  thread,
  onClose,
}: {
  thread?: DiscussionThread;
  onClose: () => void;
}) {
  const { community } = useCommunityScope();
  const me = useCurrentUser();
  const isMobile = useIsMobile();
  const toast = useToast();
  const create = useCreateThread(community.id);
  const update = useUpdateThread(community.id);
  const [text, setText] = useState(thread?.content ?? "");
  const [imageUrl, setImageUrl] = useState<string | undefined>(
    thread?.imageUrl,
  );
  const [uploadingImage, setUploadingImage] = useState(false);
  const editing = !!thread;

  const submit = async () => {
    try {
      if (thread)
        await update.mutateAsync({
          threadId: thread.id,
          patch: { content: text.trim(), imageUrl },
        });
      else await create.mutateAsync({ content: text.trim(), imageUrl });
      toast.success(
        editing ? t`Post has been updated` : t`Post has been created`,
      );
      onClose();
    } catch {
      toast.error(t`Something went wrong. Please try again.`);
    }
  };

  return (
    <Dialog
      open
      onClose={onClose}
      fullScreen={isMobile}
      slotProps={{
        paper: {
          sx: {
            width: "100%",
            maxWidth: 640,
            borderRadius: isMobile ? 0 : "10px",
            bgcolor: colors.surfaceContainerLowest,
            m: isMobile ? 0 : 2,
          },
        },
      }}
    >
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          px: "20px",
          pt: "20px",
        }}
      >
        <Avatar name={me?.displayName} imageUrl={me?.imageUrl} size={42} />
        <IconButton aria-label={t`Close`} onClick={onClose}>
          <img src="/media/x.png" alt="" width={30} height={30} />
        </IconButton>
      </Box>
      <Box sx={{ pt: "20px", overflowY: "auto", flex: 1 }}>
        {imageUrl && (
          <Box sx={{ mb: "20px", position: "relative" }}>
            <img
              src={imageUrl}
              alt={t`Attached`}
              style={{
                width: "100%",
                maxHeight: 400,
                objectFit: "cover",
                display: "block",
              }}
            />
            <ButtonBase
              aria-label={t`Remove image`}
              onClick={() => setImageUrl(undefined)}
              sx={{
                position: "absolute",
                top: 8,
                right: 8,
                bgcolor: "rgba(0,0,0,.5)",
                borderRadius: "50%",
                p: "6px",
              }}
            >
              <img
                src="/media/x.png"
                alt=""
                width={18}
                height={18}
                style={{ filter: "invert(1)" }}
              />
            </ButtonBase>
          </Box>
        )}
        <Box
          component="textarea"
          autoFocus
          aria-label={t`Post text`}
          placeholder={t`Type something`}
          value={text}
          rows={4}
          onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) =>
            setText(e.target.value)
          }
          sx={{
            display: "block",
            width: "calc(100% - 32px)",
            mx: "16px",
            border: 0,
            outline: 0,
            resize: "none",
            minHeight: 96,
            maxHeight: 240,
            fontFamily: "inherit",
            fontSize: 16,
            lineHeight: 1.5,
            color: colors.onSurface,
            bgcolor: "transparent",
          }}
        />
        <Box sx={{ px: "16px", pt: "10px", pb: "10px" }}>
          <IconButton
            onClick={() => setUploadingImage(true)}
            sx={{ gap: "10px", borderRadius: 1, color: "primary.main" }}
            aria-label={t`Attach image`}
          >
            <AttachFileRoundedIcon />
            <Typography sx={{ color: "primary.main" }}>
              <Trans>Image</Trans>
            </Typography>
          </IconButton>
        </Box>
      </Box>
      <Divider />
      <Box
        sx={{
          px: "20px",
          py: "10px",
          display: "flex",
          alignItems: "center",
          gap: "10px",
        }}
      >
        <Box
          sx={{
            flex: 1,
            display: "flex",
            overflowX: "auto",
            height: 40,
            alignItems: "center",
          }}
        >
          {EMOTIONS.map((e, i) => (
            <ButtonBase
              key={e.id}
              aria-label={t`Insert ${i18n._(e.label)}`}
              onClick={() => setText((t) => `${t}${EMOJI_CHARS[i]}`)}
              sx={{ p: "6px", borderRadius: "8px", flexShrink: 0 }}
            >
              <img src={`/media/${e.src}`} alt="" width={24} height={24} />
            </ButtonBase>
          ))}
        </Box>
        <ActionButton
          text={editing ? t`Update` : t`Post`}
          disabled={isBlank(text)}
          onPress={submit}
        />
      </Box>
      {/* Stacked above the post dialog; closing it leaves the post draft open. */}
      <AppDialog
        open={uploadingImage}
        onClose={() => setUploadingImage(false)}
        maxWidth={500}
        padding={30}
        ariaLabel={t`Upload image`}
      >
        <Box sx={{ pt: "20px" }}>
          <Upload
            onUploaded={({ url }) => {
              setImageUrl(url);
              setUploadingImage(false);
            }}
          />
        </Box>
      </AppDialog>
    </Dialog>
  );
}
