import AddIcon from "@mui/icons-material/Add";
import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import { colors } from "@/theme/tokens";
import { ActionButton } from "./ActionButton";

// A wide, quiet button that starts an optional section: a plus in a circle, then what will be added.
export function AddMoreButton({ label, onPress }: { label: string; onPress: () => unknown }) {
  return (
    <ActionButton
      expand
      color={colors.surfaceContainerHigh}
      contentAlign="start"
      onPress={onPress}
      ariaLabel={label}
      sx={{ px: "8px", py: "12px" }}
    >
      <Box sx={{ display: "flex", alignItems: "center", gap: "12px" }}>
        <Box
          aria-hidden
          sx={{
            width: 24,
            height: 24,
            borderRadius: "50%",
            bgcolor: "primary.main",
            color: "primary.contrastText",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <AddIcon sx={{ fontSize: 12 }} />
        </Box>
        <Typography sx={{ fontSize: 16, color: colors.onSurface }}>{label}</Typography>
      </Box>
    </ActionButton>
  );
}
