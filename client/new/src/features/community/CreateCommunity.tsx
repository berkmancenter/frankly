import AddIcon from "@mui/icons-material/Add";
import Box from "@mui/material/Box";
import Checkbox from "@mui/material/Checkbox";
import FormControlLabel from "@mui/material/FormControlLabel";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { t } from "@lingui/core/macro";
import { Trans } from "@lingui/react/macro";
import { useCallback, useState, type ReactElement } from "react";
import { useNavigate } from "react-router";
import { ApiError } from "@/api/api";
import { paths } from "@/app/paths";
import { ActionButton } from "@/components/ActionButton";
import { AppDialog } from "@/components/AppDialog";
import { CircleIconButton } from "@/components/CircleIconButton";
import { useGuardSignedIn } from "@/features/auth/SignInDialog";
import { useCreateCommunity } from "@/queries/communities";
import { useCurrentUser } from "@/queries/me";
import { colors, fontSizes } from "@/theme/tokens";
import { isLocalhost } from "@/utils/appInfo";
import {
  COMMUNITY_FIELD_MAX_LENGTH,
  displayIdFromName,
  filterCommunityName,
  filterDisplayId,
} from "@/utils/displayId";

/** Like Flutter, starting a community is for app owners, and for anyone when running on localhost. */
export function useCanCreateCommunity(): boolean {
  const user = useCurrentUser();
  return !!user?.isAppOwner || isLocalhost();
}

/**
 * Port of `DialogFlow().show()` behind `guardSignedIn`. The opener owns the dialog: render `dialog`
 * somewhere and call `open()`; `onDone` runs when the dialog closes, however it closed.
 */
export function useCreateCommunityDialog(onDone?: () => void): {
  open: () => void;
  dialog: ReactElement | null;
} {
  const { guard, dialog: signInDialog } = useGuardSignedIn();
  const [isOpen, setIsOpen] = useState(false);
  const open = useCallback(() => void guard(() => setIsOpen(true)), [guard]);
  const close = useCallback(() => {
    setIsOpen(false);
    onDone?.();
  }, [onDone]);

  return {
    open,
    dialog: (
      <>
        {signInDialog}
        {isOpen && <CreateCommunityDialog onClose={close} />}
      </>
    ),
  };
}

/**
 * "Start a community": a circle "+" button with a label, opening the create dialog. Renders nothing
 * for someone who may not create communities (see `useCanCreateCommunity`).
 */
export function CreateCommunityButton({
  showLabel = true,
  onDone,
}: {
  showLabel?: boolean;
  onDone?: () => void;
}) {
  const allowed = useCanCreateCommunity();
  const { open, dialog } = useCreateCommunityDialog(onDone);
  if (!allowed) return null;
  const label = t({ id: "startCommunity", message: "Start a community" });
  return (
    <>
      <Box sx={{ display: "flex", alignItems: "center", gap: "11px" }}>
        <CircleIconButton tooltip={label} icon={<AddIcon />} onClick={open} />
        {showLabel && (
          <Typography
            onClick={open}
            sx={{
              fontSize: fontSizes.md,
              color: colors.onSurface,
              letterSpacing: 0,
              cursor: "pointer",
            }}
          >
            {label}
          </Typography>
        )}
      </Box>
      {dialog}
    </>
  );
}

/**
 * Create a community dialog flow. Step one names the community (and its URL), step two
 * congratulates and opens it. The community is created when the first step is submitted.
 */
export function CreateCommunityDialog({ onClose }: { onClose: () => void }) {
  const create = useCreateCommunity();
  const [created, setCreated] = useState<{
    name: string;
    displayId: string;
  } | null>(null);

  return (
    <AppDialog
      open
      onClose={onClose}
      maxWidth={524}
      padding={40}
      fullscreenOnMobile
      ariaLabel={t({ id: "createACommunity", message: "Create a community" })}
    >
      <Typography
        component="h1"
        sx={{ fontSize: fontSizes.xl, color: colors.onSurface }}
      >
        <Trans id="createACommunity">Create a community</Trans>
      </Typography>
      {created ? (
        <Created {...created} onFinish={onClose} />
      ) : (
        <CommunityForm
          onSubmit={async (input) => {
            const result = await create.mutateAsync(input);
            setCreated({
              name: input.name.trim(),
              displayId: result.displayId,
            });
          }}
        />
      )}
    </AppDialog>
  );
}

function CommunityForm({
  onSubmit,
}: {
  onSubmit: (input: {
    name: string;
    displayId: string;
    isPublic: boolean;
  }) => Promise<void>;
}) {
  const [name, setName] = useState("");
  const [displayId, setDisplayId] = useState("");
  // Like Flutter, the URL follows the name until the person edits it themselves.
  const [urlEdited, setUrlEdited] = useState(false);
  const [isPrivate, setIsPrivate] = useState(false);
  const [attempted, setAttempted] = useState(false);
  const [touched, setTouched] = useState({ name: false, displayId: false });
  const [failure, setFailure] = useState("");

  const show = (field: "name" | "displayId") => attempted || touched[field];
  const nameError =
    show("name") && name.trim().length === 0
      ? t({ id: "enterValidName", message: "Please enter a valid name" })
      : undefined;
  const urlError =
    show("displayId") && displayId.length === 0
      ? t({
          id: "enterValidCommunityUrl",
          message: "Please enter a valid community URL",
        })
      : undefined;

  const submit = async () => {
    setAttempted(true);
    setFailure("");
    if (name.trim().length === 0 || displayId.length === 0) return;
    try {
      await onSubmit({ name, displayId, isPublic: !isPrivate });
    } catch (error) {
      setFailure(
        error instanceof ApiError && error.code === "invalid"
          ? error.message
          : t({
              id: "somethingWentWrongTryAgain",
              message: "Something went wrong. Please try again.",
            }),
      );
    }
  };

  return (
    <Box
      component="form"
      noValidate
      onSubmit={(event) => {
        event.preventDefault();
        void submit();
      }}
      sx={{ display: "flex", flexDirection: "column", gap: "24px", mt: "40px" }}
    >
      <TextField
        variant="standard"
        label={t({ id: "communityName", message: "Community Name" })}
        value={name}
        onChange={(event) => {
          const next = filterCommunityName(event.target.value);
          setName(next);
          setTouched((was) => ({ ...was, name: true }));
          if (!urlEdited) setDisplayId(displayIdFromName(next));
        }}
        error={!!nameError}
        helperText={
          nameError ??
          t({
            id: "youCanChangeThisLater",
            message: "You can change this later",
          })
        }
        slotProps={{ htmlInput: { maxLength: COMMUNITY_FIELD_MAX_LENGTH } }}
        autoFocus
      />
      <TextField
        variant="standard"
        label={t({ id: "communityUrl", message: "Community URL" })}
        value={displayId}
        onChange={(event) => {
          setDisplayId(filterDisplayId(event.target.value));
          setUrlEdited(true);
          setTouched((was) => ({ ...was, displayId: true }));
        }}
        error={!!urlError}
        helperText={urlError ?? `${window.location.origin}/space/${displayId}`}
        slotProps={{ htmlInput: { maxLength: COMMUNITY_FIELD_MAX_LENGTH } }}
      />
      <FormControlLabel
        sx={{ ml: 0 }}
        control={
          <Checkbox
            checked={isPrivate}
            onChange={(event) => setIsPrivate(event.target.checked)}
            sx={{ pl: 0 }}
          />
        }
        label={
          <Typography
            sx={{ fontSize: fontSizes.md, color: colors.onSurfaceVariant }}
          >
            <Trans id="makeThisSpacePrivate">Make this space private</Trans>
          </Typography>
        }
      />
      {failure && (
        <Typography role="alert" sx={{ color: colors.error }}>
          {failure}
        </Typography>
      )}
      <Box sx={{ display: "flex", justifyContent: "flex-end" }}>
        <ActionButton
          text={t({ id: "next", message: "Next" })}
          color={colors.primary}
          textColor={colors.onPrimary}
          onPress={submit}
        />
      </Box>
    </Box>
  );
}

function Created({
  name,
  displayId,
  onFinish,
}: {
  name: string;
  displayId: string;
  onFinish: () => void;
}) {
  const navigate = useNavigate();
  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: "10px",
        mt: "40px",
        textAlign: "center",
      }}
    >
      <img src="/media/congrats.png" alt="" width={80} height={80} />
      <Typography
        component="h2"
        sx={{ fontSize: fontSizes["3xl"], fontWeight: 700 }}
      >
        <Trans id="congratulations">Congratulations!</Trans>
      </Typography>
      <Typography sx={{ fontSize: fontSizes.md }}>
        <Trans id="communitySuccessPrefix">
          You've successfully created your community
        </Trans>
        <br />
        <strong>{name}</strong>.
      </Typography>
      <Typography sx={{ fontSize: fontSizes.md }}>
        <Trans id="communitySuccessSuffix">
          Click the gear icon in the top right to edit your community settings.
        </Trans>
      </Typography>
      <Box sx={{ alignSelf: "flex-end" }}>
        <ActionButton
          text={t({ id: "finish", message: "Finish" })}
          color={colors.primary}
          textColor={colors.onPrimary}
          onPress={() => {
            onFinish();
            navigate(paths.community(displayId).home);
          }}
        />
      </Box>
    </Box>
  );
}
