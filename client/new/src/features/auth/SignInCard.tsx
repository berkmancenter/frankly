import Box from "@mui/material/Box";
import { colors } from "@/theme/tokens";
import { SignInForm } from "./SignInForm";

/** The sign-in / sign-up form on a centered card, for pages that are only useful to a registered user. */
export function SignInCard() {
  return (
    <Box sx={{ display: "flex", justifyContent: "center", px: "20px", py: "40px" }}>
      <Box
        sx={{
          width: "100%",
          maxWidth: 400,
          p: "40px",
          borderRadius: "20px",
          bgcolor: colors.surfaceContainerLowest,
        }}
      >
        <SignInForm />
      </Box>
    </Box>
  );
}
