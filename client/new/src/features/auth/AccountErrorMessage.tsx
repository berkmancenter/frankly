import Box from "@mui/material/Box";
import Link from "@mui/material/Link";
import { alpha } from "@mui/material/styles";
import { Trans } from "@lingui/react/macro";
import type { ReactNode } from "react";
import { colors } from "@/theme/tokens";
import { appName, supportEmail } from "@/utils/appInfo";

/** Inline text that acts like a link (Flutter's `buildActionText`). */
export function ActionText({
  onClick,
  children,
}: {
  onClick: () => void;
  children: ReactNode;
}) {
  return (
    <Link
      component="button"
      type="button"
      underline="always"
      color="inherit"
      onClick={onClick}
      sx={{ font: "inherit", verticalAlign: "baseline", textAlign: "inherit" }}
    >
      {children}
    </Link>
  );
}

function ContactLink() {
  return (
    <Link href={`mailto:${supportEmail}`} underline="always" color="inherit">
      <Trans id="contactUs">Contact us</Trans>
    </Link>
  );
}

/**
 * Builds a forgot-password message with an action to reset the password.
 *
 * @param showEmailLink Whether to show the option to enter an email address.
 * @param onEnterEmail Callback for the enter-email action.
 * @param onForgotPassword Callback invoked when the reset-password action is clicked.
 * @returns The forgot-password message and its actions.
 */
export function ForgotPasswordMessage({
  showEmailLink = true,
  onEnterEmail,
  onForgotPassword,
}: {
  showEmailLink?: boolean;
  onEnterEmail?: () => void;
  onForgotPassword: () => void;
}) {
  return (
    <p style={{ textAlign: "left" }}>
      <Trans id="forgotPasswordPrefix">Forgot your password?</Trans>{" "}
      {showEmailLink && onEnterEmail ? (
        <>
          <ActionText onClick={onEnterEmail}>
            <Trans id="forgotPasswordEnterEmail">Enter your email</Trans>
          </ActionText>
          , <Trans id="forgotPasswordThen">then </Trans>
        </>
      ) : (
        <>
          <Trans id="forgotPasswordEnterEmail">Enter your email</Trans>{" "}
        </>
      )}
      <ActionText onClick={onForgotPassword}>
        <Trans id="forgotPasswordSuffix">reset your password</Trans>
      </ActionText>
      .
    </p>
  );
}

/**
 * The boxed explanation under the title when sign-in or sign-up fails. `errorCode` is an
 * `AuthError.code`; anything unrecognized gets the generic "something went wrong".
 */
export function AccountErrorMessage({
  errorCode,
  onSwitchView,
  onForgotPassword,
  onEnterEmail,
}: {
  errorCode: string;
  /** `true` switches to sign-up, `false` to log-in. */
  onSwitchView: (signUp: boolean) => void;
  onForgotPassword: () => void;
  onEnterEmail: () => void;
}) {
  return (
    <Box
      role="alert"
      tabIndex={-1}
      sx={{
        p: "20px",
        mt: "10px",
        bgcolor: alpha(colors.error, 0.05),
        whiteSpace: "pre-line",
      }}
    >
      <ErrorBody
        errorCode={errorCode}
        onSwitchView={onSwitchView}
        onForgotPassword={onForgotPassword}
        onEnterEmail={onEnterEmail}
      />
    </Box>
  );
}

function ErrorBody({
  errorCode,
  onSwitchView,
  onForgotPassword,
  onEnterEmail,
}: {
  errorCode: string;
  onSwitchView: (signUp: boolean) => void;
  onForgotPassword: () => void;
  onEnterEmail: () => void;
}) {
  switch (errorCode) {
    case "email-already-in-use":
      return (
        <>
          <Trans id="emailAddressAlreadyInUseLoginError">
            This email is already in use. Try{" "}
          </Trans>
          <ActionText onClick={() => onSwitchView(false)}>
            <Trans id="loggingIn">logging in</Trans>
          </ActionText>
          <Trans id="insteadSuffix"> instead.</Trans>
        </>
      );
    case "user-not-found":
      return (
        <>
          <Trans id="couldntFindAccount">
            We couldn’t find an account with this email. Try{" "}
          </Trans>
          <ActionText onClick={() => onSwitchView(true)}>
            <Trans id="signingUp">signing up</Trans>
          </ActionText>
          <Trans id="insteadSuffix"> instead.</Trans>
        </>
      );
    case "invalid-credential":
    case "wrong-password":
      return (
        <Box sx={{ display: "flex", flexDirection: "column", gap: "15px" }}>
          <Box sx={{ fontWeight: "bold" }}>
            <Trans id="emailAndPasswordMismatch">
              Your email and password combination don’t match a {appName}{" "}
              account.
            </Trans>
          </Box>
          <Box>
            <ActionText onClick={onEnterEmail}>
              <Trans id="emailAndPasswordMismatchCheck">
                You can check what you entered and try again.
              </Trans>
            </ActionText>
          </Box>
          <Box>
            <Trans id="forgotEmail">
              Forgot the email associated with your account?
            </Trans>{" "}
            <ContactLink />.
          </Box>
          <Box>
            <ForgotPasswordMessage
              onEnterEmail={onEnterEmail}
              onForgotPassword={onForgotPassword}
            />
          </Box>
        </Box>
      );
    case "invalid-email":
      return <Trans id="invalidEmail">Invalid email</Trans>;
    case "too-many-requests":
      return (
        <Trans id="tooManyRequests">
          Too many failed requests. Please try again later.
        </Trans>
      );
    case "email-missing-pw":
      return (
        <Trans id="pleaseEnterValidEmail">
          Please enter a valid email address.
        </Trans>
      );
    default:
      return (
        <>
          <Box component="span" sx={{ fontWeight: "bold" }}>
            <Trans id="somethingWentWrongLongPrefix">
              We’re sorry, something went wrong.
            </Trans>
            {"\n\n"}
          </Box>
          <Trans id="somethingWentWrongLongMiddle">
            Refresh the page and try logging in to Frankly again.{"\n\n"}If you
            continue having trouble, you can
          </Trans>{" "}
          <Link
            href={`mailto:${supportEmail}`}
            underline="always"
            color="inherit"
          >
            <Trans id="somethingWentWrongLongSuffix">
              contact us for support
            </Trans>
          </Link>
          <Trans id="tryAgainLater"> and try again later</Trans>.
        </>
      );
  }
}
