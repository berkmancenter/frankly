import CloudUploadOutlinedIcon from "@mui/icons-material/CloudUploadOutlined";
import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import LinearProgress from "@mui/material/LinearProgress";
import Typography from "@mui/material/Typography";
import { t } from "@lingui/core/macro";
import { useEffect, useRef, useState, type DragEvent } from "react";
import { colors, fontSizes } from "@/theme/tokens";
import {
  isAbortError,
  resolveImageUploadProvider,
  type UploadedImage,
} from "@/utils/imageUpload";
import { useIsMobile } from "@/utils/useResponsive";

const DEFAULT_MAX_BYTES = 10 * 1024 * 1024;

// The environment can't change while the app runs, so resolve it once.
const configured = resolveImageUploadProvider();

interface UploadProps {
  /** Called once the provider has stored the image. */
  onUploaded: (image: UploadedImage, file: File) => void;
  /** `<input accept>` value (default: any image). */
  accept?: string;
  maxBytes?: number;
  /** Zone height in px. */
  height?: number;
}

/**
 * Image picker + uploader. Meant to be the body of an `AppDialog`:
 *
 *   <AppDialog open={open} onClose={close} maxWidth={500}>
 *     <Upload onUploaded={({ url }) => { save(url); close(); }} />
 *   </AppDialog>
 *
 * The image host comes from the environment (see `resolveImageUploadProvider`); with none
 * configured the widget shows that error instead of the drop zone.
 *
 * Desktop accepts a dropped file or a click-to-browse; on mobile there is no drag-and-drop, only
 * the native file picker (which also offers the camera).
 */
export function Upload({
  onUploaded,
  accept = "image/*",
  maxBytes = DEFAULT_MAX_BYTES,
  height = 220,
}: UploadProps) {
  const isMobile = useIsMobile();
  const inputRef = useRef<HTMLInputElement>(null);
  const abortRef = useRef<AbortController | null>(null);
  const [dragging, setDragging] = useState(false);
  const [progress, setProgress] = useState<number | null>(null);
  const [error, setError] = useState<string | null>(null);
  const uploading = progress !== null;

  useEffect(() => () => abortRef.current?.abort(), []);

  if (!configured.provider) {
    return (
      <Typography role="alert" sx={{ color: colors.error }}>
        {configured.error}
      </Typography>
    );
  }
  const { provider } = configured;

  const start = async (file: File) => {
    const problem = validate(file, accept, maxBytes);
    if (problem) return setError(problem);

    const controller = new AbortController();
    abortRef.current = controller;
    setError(null);
    setProgress(0);
    try {
      const image = await provider.upload(file, {
        onProgress: setProgress,
        signal: controller.signal,
      });
      onUploaded(image, file);
    } catch (e) {
      if (!isAbortError(e)) {
        setError(e instanceof Error ? e.message : t`Upload failed`);
      }
    } finally {
      abortRef.current = null;
      setProgress(null);
    }
  };

  const onDrop = (e: DragEvent) => {
    e.preventDefault();
    setDragging(false);
    const file = e.dataTransfer.files[0];
    if (file && !uploading) void start(file);
  };

  // Drag handlers are only attached on desktop; on mobile the zone is just a button.
  const dragProps = isMobile
    ? {}
    : {
        onDragOver: (e: DragEvent) => {
          e.preventDefault();
          if (!uploading) setDragging(true);
        },
        onDragLeave: () => setDragging(false),
        onDrop,
      };

  return (
    <Box>
      <ButtonBase
        component="div"
        disabled={uploading}
        onClick={() => inputRef.current?.click()}
        {...dragProps}
        sx={{
          width: "100%",
          height,
          display: "flex",
          flexDirection: "column",
          gap: "12px",
          borderRadius: "10px",
          border: "2px dashed",
          borderColor: dragging ? "primary.main" : colors.outline,
          bgcolor: dragging ? colors.surfaceContainer : colors.surface,
          textAlign: "center",
          px: "20px",
        }}
      >
        <CloudUploadOutlinedIcon sx={{ fontSize: 40, color: colors.onSurfaceVariant }} />
        <Typography sx={{ fontSize: fontSizes.md, fontWeight: 500 }}>
          {isMobile ? t`Choose a photo` : t`Drag and drop an image here`}
        </Typography>
        {!isMobile && (
          <Typography sx={{ color: colors.onSurfaceVariant }}>
            {t`or click to browse`}
          </Typography>
        )}
      </ButtonBase>
      <input
        ref={inputRef}
        type="file"
        accept={accept}
        hidden
        onChange={(e) => {
          const file = e.target.files?.[0];
          // Reset so picking the same file again after an error still fires `change`.
          e.target.value = "";
          if (file) void start(file);
        }}
      />
      {uploading && (
        <Box sx={{ mt: "16px", display: "flex", alignItems: "center", gap: "12px" }}>
          <LinearProgress variant="determinate" value={progress} sx={{ flex: 1 }} />
          <ButtonBase
            onClick={() => abortRef.current?.abort()}
            sx={{ textDecoration: "underline", fontSize: fontSizes.sm }}
          >
            {t`Cancel`}
          </ButtonBase>
        </Box>
      )}
      {error && (
        <Typography role="alert" sx={{ mt: "12px", color: colors.error }}>
          {error}
        </Typography>
      )}
    </Box>
  );
}

function validate(file: File, accept: string, maxBytes: number): string | null {
  const allowed = accept.split(",").map((a) => a.trim());
  const ok = allowed.some((a) =>
    a.endsWith("/*")
      ? file.type.startsWith(a.slice(0, -1))
      : a.startsWith(".")
        ? file.name.toLowerCase().endsWith(a.toLowerCase())
        : file.type === a,
  );
  if (!ok) return t`That file type isn't supported.`;
  if (file.size > maxBytes) {
    return t`That file is too large (max ${Math.round(maxBytes / 1024 / 1024)} MB).`;
  }
  return null;
}
