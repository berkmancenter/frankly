import Visibility from "@mui/icons-material/Visibility";
import VisibilityOff from "@mui/icons-material/VisibilityOff";
import Box from "@mui/material/Box";
import IconButton from "@mui/material/IconButton";
import Link from "@mui/material/Link";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { t } from "@lingui/core/macro";
import { Trans } from "@lingui/react/macro";
import { useRef, useState, type KeyboardEvent } from "react";
import { useAuthService } from "@/api/ApiProvider";
import { AuthError } from "@/api/auth";
import { ActionButton } from "@/components/ActionButton";
import { colors, fontSizes } from "@/theme/tokens";
import { appName, supportEmail, termsUrl } from "@/utils/appInfo";
import {
  AccountErrorMessage,
  ActionText,
  ForgotPasswordMessage,
} from "./AccountErrorMessage";
import { isEmailValid, isPasswordValid } from "./validation";

type FieldErrors = { name?: string; email?: string; password?: string };

/**
 * Sign in / sign up with email and password, or with Google. Port of Flutter's
 * `SignInOptionsContent`. Calls `onSignedIn` once the account call succeeds; the session
 * itself then updates through `useAuthSession`.
 */
export function SignInForm({
  showSignUp = true,
  onSignedIn,
}: {
  showSignUp?: boolean;
  onSignedIn?: () => void;
}) {
  const auth = useAuthService();
  const [signUp, setSignUp] = useState(showSignUp);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [errors, setErrors] = useState<FieldErrors>({});
  const [errorCode, setErrorCode] = useState("");
  const [message, setMessage] = useState("");
  const emailRef = useRef<HTMLInputElement>(null);
  const submitting = useRef(false);

  const reportError = (error: unknown) =>
    setErrorCode(error instanceof AuthError ? error.code : "unknown");

  const validate = (): boolean => {
    const next: FieldErrors = {};
    if (signUp && name.trim().length === 0) {
      next.name = t({
        id: "enterValidName",
        message: "Please enter a valid name",
      });
    }
    if (email.length === 0 || !isEmailValid(email)) {
      next.email = t({
        id: "pleaseEnterValidEmail",
        message: "Please enter a valid email address.",
      });
    }
    // Existing accounts may predate the complexity rule, so only check the format at sign-up.
    if (!signUp && password.length === 0) {
      next.password = t({
        id: "pleaseEnterValidPassword",
        message: "Please enter a valid password",
      });
    } else if (signUp && !isPasswordValid(password)) {
      next.password = t({
        id: "pleaseEnterPassword",
        message: "Please enter a password",
      });
    }
    setErrors(next);
    return Object.keys(next).length === 0;
  };

  const submit = async () => {
    if (submitting.current || !validate()) return;
    submitting.current = true;
    setMessage("");
    try {
      if (signUp) {
        await auth.registerWithEmail({
          displayName: name.trim(),
          email: email.trim(),
          password,
        });
      } else {
        await auth.signInWithEmail(email.trim(), password);
      }
      setErrorCode("");
      onSignedIn?.();
    } catch (error) {
      reportError(error);
    } finally {
      submitting.current = false;
    }
  };

  const resetPassword = async () => {
    try {
      await auth.sendPasswordReset(email.trim());
      setErrorCode("");
      setMessage(
        t({
          id: "passwordResetLinkSent",
          message: `Password reset link sent to ${email}`,
        }),
      );
    } catch (error) {
      setMessage("");
      reportError(error);
    }
  };

  const switchMode = (toSignUp: boolean) => {
    setSignUp(toSignUp);
    setErrorCode("");
    setErrors({});
  };

  const focusEmail = () => emailRef.current?.focus();

  const onKeyDown = (event: KeyboardEvent) => {
    if (event.key === "Enter" && event.target instanceof HTMLInputElement) {
      event.preventDefault();
      void submit();
    }
  };

  return (
    <Box
      component="form"
      noValidate
      onSubmit={(event) => event.preventDefault()}
      onKeyDown={onKeyDown}
      sx={{
        display: "flex",
        flexDirection: "column",
        textAlign: "center",
      }}
    >
      <Typography
        component="h2"
        sx={{ fontSize: fontSizes.xl, color: colors.onSurface }}
      >
        {signUp ? (
          <Trans id="newToApp">New to {appName}?</Trans>
        ) : (
          <Trans id="logIntoApp">Log into {appName}</Trans>
        )}
      </Typography>

      <Typography sx={{ mt: "9px" }}>
        {signUp ? (
          <Trans id="alreadyUserSignIn">Already have an account?</Trans>
        ) : (
          <Trans id="notUserSignUp">Don't have an account?</Trans>
        )}{" "}
        <ActionText onClick={() => switchMode(!signUp)}>
          {signUp ? (
            <Trans id="login">Login</Trans>
          ) : (
            <Trans id="signUp">Sign Up</Trans>
          )}
        </ActionText>
        .
      </Typography>

      {errorCode && (
        <AccountErrorMessage
          errorCode={errorCode}
          onSwitchView={switchMode}
          onForgotPassword={resetPassword}
          onEnterEmail={focusEmail}
        />
      )}
      {message && (
        <Typography role="status" sx={{ mt: "9px", fontSize: fontSizes.xs }}>
          {message}
        </Typography>
      )}

      <Box
        sx={{
          display: "flex",
          flexDirection: "column",
          gap: "10px",
          mt: "10px",
        }}
      >
        {signUp && (
          <TextField
            variant="standard"
            label={t({ id: "yourName", message: "Your Name" })}
            placeholder={t({ id: "nameHintExample", message: "e.g. Jane Doe" })}
            value={name}
            onChange={(e) => setName(e.target.value)}
            error={!!errors.name}
            helperText={errors.name}
            autoComplete="name"
          />
        )}
        <TextField
          variant="standard"
          type="email"
          label={t({ id: "email", message: "Email" })}
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          error={!!errors.email}
          helperText={errors.email}
          autoComplete="username"
          inputRef={emailRef}
        />
        <TextField
          variant="standard"
          type={showPassword ? "text" : "password"}
          label={t({ id: "password", message: "Password" })}
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          error={!!errors.password}
          helperText={errors.password}
          autoComplete={signUp ? "new-password" : "current-password"}
          slotProps={{
            input: {
              endAdornment: (
                <IconButton
                  aria-label={
                    showPassword
                      ? t({ id: "hidePassword", message: "Hide password" })
                      : t({ id: "showPassword", message: "Show Password" })
                  }
                  onClick={() => setShowPassword((shown) => !shown)}
                  edge="end"
                >
                  {showPassword ? <VisibilityOff /> : <Visibility />}
                </IconButton>
              ),
            },
          }}
        />
      </Box>

      {signUp ? (
        <Typography sx={{ mt: "20px" }} align="left">
          <Trans id="passwordRequirements">
            Must be at least 12 characters long, and contain one lowercase and
            one uppercase letter.
          </Trans>
        </Typography>
      ) : (
        <Typography sx={{ mt: "20px" }}>
          <ForgotPasswordMessage
            onForgotPassword={resetPassword}
            onEnterEmail={focusEmail}
          />
        </Typography>
      )}

      <Box sx={{ mt: "20px" }}>
        <ActionButton
          expand
          color={colors.onSurface}
          textColor={colors.surfaceContainerLowest}
          onPress={submit}
          text={
            signUp
              ? t({ id: "signUp", message: "Sign Up" })
              : t({ id: "signIn", message: "Log In" })
          }
        />
      </Box>

      <Typography sx={{ mt: "9px", fontWeight: "400" }}>
        <Trans id="or">Or</Trans>
      </Typography>

      <Box sx={{ mt: "9px" }}>
        <ActionButton
          type="outline"
          expand
          onPress={async () => {
            try {
              await auth.signInWithGoogle();
            } catch (error) {
              reportError(error);
            }
          }}
          icon={
            <img src="/media/googleLogo.png" alt="" width={22} height={22} />
          }
          text={
            signUp
              ? t({ id: "signUpWithGoogle", message: "Sign up with Google" })
              : t({ id: "logInWithGoogle", message: "Log in with Google" })
          }
        />
      </Box>

      {!signUp && (
        <Typography sx={{ mt: "20px" }} align="left">
          <Trans id="forgotAccountEmailOrNeedHelp">
            Forgot your account email or need other help signing in?
          </Trans>{" "}
          <Link
            href={`mailto:${supportEmail}`}
            underline="always"
            color="inherit"
          >
            <Trans id="contactUs">Contact us</Trans>
          </Link>
          .
        </Typography>
      )}

      <Typography sx={{ mt: "20px" }} align="left">
        <Trans id="termsAgreementPrefix">
          By signing in, registering, or using {appName}, I agree to be bound by
          the{" "}
        </Trans>
        <Link
          href={termsUrl}
          target="_blank"
          rel="noopener"
          underline="always"
          color="inherit"
        >
          <Trans id="termsOfService">{appName} Terms of Service</Trans>
        </Link>
        .
      </Typography>
    </Box>
  );
}
