import Box from "@mui/material/Box";
import type { SxProps, Theme } from "@mui/material/styles";
import { initials } from "@/utils/format";

interface AvatarProps {
  name?: string | null;
  imageUrl?: string | null;
  size?: number;
  /** 2px ring in `surfaceContainer` (the ProfileChip look). */
  ring?: boolean;
  sx?: SxProps<Theme>;
}

/** Circle with the user's picture; falls back to their first letter on a `primary` background. */
export function Avatar({
  name,
  imageUrl,
  size = 42,
  ring = true,
  sx,
}: AvatarProps) {
  return (
    <Box
      aria-hidden={!name}
      title={name ?? undefined}
      sx={[
        {
          width: size,
          height: size,
          borderRadius: "50%",
          boxSizing: "border-box",
          border: ring ? "2px solid" : "none",
          borderColor: "m3.surfaceContainer",
          bgcolor: "primary.main",
          color: "primary.contrastText",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          overflow: "hidden",
          flexShrink: 0,
          fontSize: Math.max(11, Math.round(size * 0.38)),
          fontWeight: 500,
          lineHeight: 1,
        },
        ...(Array.isArray(sx) ? sx : [sx]),
      ]}
    >
      {imageUrl ? (
        <img
          src={imageUrl}
          alt=""
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
            display: "block",
          }}
        />
      ) : (
        initials(name)
      )}
    </Box>
  );
}
