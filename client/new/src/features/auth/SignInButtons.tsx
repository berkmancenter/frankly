import Box from "@mui/material/Box";
import { t } from "@lingui/core/macro";
import { ActionButton } from "@/components/ActionButton";
import { useSignInDialog } from "./SignInDialog";

/**
 * "Log In" / "Sign Up" for a visitor without an account (Flutter's `SignInWidget`). Flutter sends
 * them to the home page; there is none here yet, so each opens the sign-in dialog.
 */
export function SignInButtons() {
  const { open, dialog } = useSignInDialog();
  return (
    <Box sx={{ display: "flex", alignItems: "center", gap: "8px", px: "8px" }}>
      {/* Not returning the dialog's promise: the button would show a spinner while it is open. */}
      <ActionButton
        type="text"
        text={t({ id: "signIn", message: "Log In" })}
        onPress={() => {
          void open({ newUser: false });
        }}
      />
      <ActionButton
        text={t({ id: "signUp", message: "Sign Up" })}
        onPress={() => {
          void open({ newUser: true });
        }}
      />
      {dialog}
    </Box>
  );
}
