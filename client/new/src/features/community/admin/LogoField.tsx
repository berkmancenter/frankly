import AddIcon from "@mui/icons-material/Add";
import EditIcon from "@mui/icons-material/Edit";
import ImageOutlinedIcon from "@mui/icons-material/ImageOutlined";
import Box from "@mui/material/Box";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import { ActionButton } from "@/components/ActionButton";
import { AppDialog } from "@/components/AppDialog";
import { Img } from "@/components/Img";
import { Upload } from "@/components/Upload";
import { colors } from "@/theme/tokens";
import { useIsMobile } from "@/utils/useResponsive";

const SIZE = 80;

// The community's logo: a circle with upload (or edit) and remove buttons. Both buttons act at once.
export function LogoField({
  image,
  onUpload,
  onRemove,
}: {
  image?: string;
  onUpload: (url: string) => Promise<unknown> | void;
  onRemove: () => Promise<unknown> | void;
}) {
  const { t } = useLingui();
  const isMobile = useIsMobile();
  const [uploading, setUploading] = useState(false);
  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: isMobile ? "column" : "row",
        alignItems: "center",
        gap: "30px",
      }}
    >
      <Box
        sx={{
          width: SIZE + 10,
          height: SIZE + 10,
          borderRadius: "50%",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          overflow: "hidden",
          bgcolor: image ? "transparent" : colors.surfaceContainerHighest,
          border: image ? "1px solid" : "none",
          borderColor: "primary.main",
        }}
      >
        {image ? (
          <Img src={image} width={SIZE} height={SIZE} radius="50%" />
        ) : (
          <ImageOutlinedIcon sx={{ fontSize: SIZE, color: "primary.main" }} />
        )}
      </Box>
      <Box sx={{ display: "flex", gap: "10px" }}>
        <ActionButton
          type="outline"
          icon={image ? <EditIcon /> : <AddIcon />}
          onPress={() => setUploading(true)}
        >
          {image
            ? t({ id: "edit", message: "Edit" })
            : t({ id: "upload", message: "Upload" })}
        </ActionButton>
        {image && (
          <ActionButton type="outline" onPress={onRemove}>
            {t({ id: "remove", message: "Remove" })}
          </ActionButton>
        )}
      </Box>
      <AppDialog
        open={uploading}
        onClose={() => setUploading(false)}
        maxWidth={500}
        ariaLabel={t({ id: "logo", message: "Logo" })}
      >
        <Upload
          onUploaded={({ url }) => {
            setUploading(false);
            void onUpload(url.trim());
          }}
        />
      </AppDialog>
    </Box>
  );
}
