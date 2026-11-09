import Box from "@mui/material/Box";
import Dialog from "@mui/material/Dialog";
import IconButton from "@mui/material/IconButton";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { useState } from "react";
import type { DiscussionThread } from "@/api/types";
import { ActionButton } from "@/components/ActionButton";
import { useToast } from "@/components/Toast";
import { isBlank } from "@/utils/strings";
import { useIsMobile } from "@/utils/useResponsive";
import { useAddComment } from "@/queries/threads";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { colors, fontSizes } from "@/theme/tokens";

/** "Add comment" compose dialog (also used for replies to a comment). */
export function AddCommentDialog({
  thread,
  replyToCommentId,
  onClose,
}: {
  thread: Pick<DiscussionThread, "id">;
  replyToCommentId?: string;
  onClose: () => void;
}) {
  const { community } = useCommunityScope();
  const isMobile = useIsMobile();
  const toast = useToast();
  const add = useAddComment(thread.id, community.id);
  const [text, setText] = useState("");
  const [touched, setTouched] = useState(false);
  const empty = isBlank(text);

  return (
    <Dialog
      open
      onClose={onClose}
      slotProps={{
        paper: {
          sx: {
            width: "100%",
            maxWidth: 600,
            maxHeight: 600,
            borderRadius: "10px",
            p: isMobile ? "20px" : "40px",
            bgcolor: colors.surfaceContainerLowest,
          },
        },
      }}
    >
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
        }}
      >
        <Typography
          component="h2"
          sx={{ fontSize: isMobile ? fontSizes["3xl"] : fontSizes["2xl"] }}
        >
          Add comment
        </Typography>
        <IconButton aria-label="Close" onClick={onClose}>
          <img src="/media/x.png" alt="" width={32} height={32} />
        </IconButton>
      </Box>
      <TextField
        sx={{ mt: "16px" }}
        label="Comment"
        autoFocus
        multiline
        minRows={3}
        maxRows={15}
        value={text}
        onChange={(e) => setText(e.target.value)}
        onBlur={() => setTouched(true)}
        error={touched && empty}
        helperText={touched && empty ? "Comment cannot be empty" : undefined}
      />
      <Box sx={{ display: "flex", justifyContent: "flex-end", mt: "16px" }}>
        <ActionButton
          text="Add comment"
          onPress={async () => {
            setTouched(true);
            if (empty) return;
            try {
              await add.mutateAsync({ comment: text.trim(), replyToCommentId });
              onClose();
            } catch {
              toast.error("Something went wrong. Please try again.");
            }
          }}
        />
      </Box>
    </Dialog>
  );
}
