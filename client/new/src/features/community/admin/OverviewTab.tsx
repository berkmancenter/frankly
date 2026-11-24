import Box from "@mui/material/Box";
import Divider from "@mui/material/Divider";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useState, type ReactNode } from "react";
import { useNavigate } from "react-router";
import {
  COMMUNITY_LINK_FIELDS,
  type Community,
  type CommunityLinkField,
} from "@/api/types";
import { ApiError, type CommunityUpdate } from "@/api/api";
import { paths } from "@/app/paths";
import { ActionButton } from "@/components/ActionButton";
import { useConfirm } from "@/components/ConfirmDialog";
import { useToast } from "@/components/Toast";
import { useUpdateCommunity } from "@/queries/communities";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { colors, fontSizes } from "@/theme/tokens";
import { isColorComboValid, isColorValid } from "@/utils/communityTheme";
import { filterCommunityName, filterDisplayId } from "@/utils/displayId";
import { useIsMobile } from "@/utils/useResponsive";
import { LogoField } from "./LogoField";
import { ThemeColorSection } from "./ThemeColorSection";
import {
  BRAND_NAMES,
  DISPLAY_ID_MAX_LENGTH,
  EXAMPLE_ADDRESSES,
  EXAMPLE_EMAIL,
  FIELD,
  NAME_MAX_LENGTH,
  TAGLINE_MAX_LENGTH,
  draftOf,
  isDisplayIdValid,
  isEmailValid,
  linkProblem,
  placeholderLogo,
  type ProfileDraft,
} from "./communityProfile";

// The Profile tab: the community's name, address, links, logo and colors.
export function OverviewTab() {
  const { community } = useCommunityScope();
  // A saved change (a new logo, say) comes back as a new community; start the form from it only
  // when the admin moves to another community.
  return <ProfileForm key={community.id} community={community} />;
}

function Section({ label, children }: { label: string; children: ReactNode }) {
  const isMobile = useIsMobile();
  return (
    <Box
      sx={{
        display: isMobile ? "block" : "grid",
        gridTemplateColumns: "1fr 2fr 1fr",
        alignItems: "start",
      }}
    >
      <Typography
        component="h2"
        sx={{
          fontSize: fontSizes.xl,
          pt: isMobile ? "20px" : "30px",
          pl: isMobile ? "8px" : "50px",
        }}
      >
        {label}
      </Typography>
      <Box sx={{ py: isMobile ? "20px" : "36px", px: "8px", minWidth: 0 }}>
        {children}
      </Box>
    </Box>
  );
}

function ProfileForm({ community }: { community: Community }) {
  const { t } = useLingui();
  const toast = useToast();
  const navigate = useNavigate();
  const update = useUpdateCommunity();
  const { confirm, dialog } = useConfirm();
  const [draft, setDraft] = useState<ProfileDraft>(() => draftOf(community));
  const [touched, setTouched] = useState<Set<string>>(new Set());
  const [logo, setLogo] = useState(community.profileImageUrl);

  const set = <K extends keyof ProfileDraft>(
    key: K,
    value: ProfileDraft[K],
  ) => {
    setDraft((current) => ({ ...current, [key]: value }));
    setTouched((current) => new Set(current).add(key));
  };
  const setLink = (field: CommunityLinkField, value: string) => {
    setDraft((current) => ({
      ...current,
      links: { ...current.links, [field]: value },
    }));
    setTouched((current) => new Set(current).add(field));
  };
  const shows = (key: string) => touched.has(key);

  const nameError =
    shows(FIELD.name) && !draft.name.trim()
      ? t({ id: "enterValidName", message: "Please enter a valid name" })
      : undefined;
  const displayIdError =
    shows(FIELD.displayId) && !draft.displayId
      ? t({
          id: "enterValidCommunityUrl",
          message: "Please enter a valid community URL",
        })
      : undefined;
  const emailError =
    shows(FIELD.contactEmail) && !isEmailValid(draft.contactEmail)
      ? t({
          id: "pleaseEnterValidEmail",
          message: "Please enter a valid email address.",
        })
      : undefined;
  const linkError = (field: CommunityLinkField, platform: string) => {
    const problem = shows(field)
      ? linkProblem(field, draft.links[field])
      : undefined;
    if (!problem) return undefined;
    const url = problem.kind === "host" ? problem.host : "";
    return problem.kind === "website"
      ? t({
          id: "enterValidWebsiteUrl",
          message: "Enter a valid web address (e.g. “https://websitename.com”)",
        })
      : t({
          id: "enterValidSocialUrl",
          message: `Enter a valid ${platform} web address that includes “${url}”`,
        });
  };

  const platformNames = (field: CommunityLinkField) =>
    BRAND_NAMES[field] ?? t({ id: "websiteUrl", message: "Website URL" });

  const refuse = (message: string) =>
    confirm({
      title: t({
        id: "yourChangesToProfileCantBeSaved",
        message: "Your changes to Profile can't be saved",
      }),
      mainText: message,
      confirmText: t({ id: "close", message: "Close" }),
    });

  const save = async () => {
    const firstProblem = [
      !draft.name.trim() &&
        t({
          id: "errorCommunityNameEmpty",
          message: "Community name cannot be empty",
        }),
      !draft.displayId &&
        t({
          id: "errorCommunityUrlEmpty",
          message: "Community URL cannot be empty",
        }),
      !isDisplayIdValid(draft.displayId) &&
        t({
          id: "displayIdWarning",
          message:
            "URL display name can only contain letters, numbers, and dashes.",
        }),
    ].find(Boolean);
    if (firstProblem) return void (await refuse(firstProblem));

    const fieldsInvalid =
      !isEmailValid(draft.contactEmail) ||
      COMMUNITY_LINK_FIELDS.some((field) =>
        linkProblem(field, draft.links[field]),
      );
    if (fieldsInvalid) {
      setTouched(
        new Set<string>([
          FIELD.name,
          FIELD.displayId,
          FIELD.contactEmail,
          ...COMMUNITY_LINK_FIELDS,
        ]),
      );
      return void (await refuse(
        t({
          id: "errorCommunityProfile",
          message:
            "Entries for one or more Profile settings need to be changed. Correct any errors and try again. ",
        }),
      ));
    }

    const hasColors = draft.light !== "" || draft.dark !== "";
    if (hasColors && !isColorComboValid(draft.light, draft.dark)) {
      return void (await refuse(
        t({
          id: "selectedColorsContrastError",
          message:
            "The selected colors do not have sufficient contrast. Please choose different colors.",
        }),
      ));
    }

    const newDisplayId = draft.displayId !== community.displayId;
    const patch: CommunityUpdate = {
      name: draft.name,
      tagLine: draft.tagLine,
      description: draft.description,
      contactEmail: draft.contactEmail,
      ...draft.links,
      ...(hasColors && isColorValid(draft.light) && isColorValid(draft.dark)
        ? { themeLightColor: draft.light, themeDarkColor: draft.dark }
        : {}),
      ...(newDisplayId ? { displayId: draft.displayId } : {}),
    };
    try {
      await update.mutateAsync({ community, patch });
    } catch (error) {
      if (error instanceof ApiError && error.code === "invalid") {
        return void (await refuse(error.message));
      }
      return void toast.error(
        t({
          id: "somethingWentWrongTryAgain",
          message: "Something went wrong. Please try again.",
        }),
      );
    }
    if (newDisplayId) {
      navigate(paths.community(draft.displayId).admin("profile"));
    }
    toast.success(t({ id: "changesSaved", message: "Changes Saved" }));
  };

  const saveLogo = async (url: string | undefined) => {
    if (!url || url === logo) return;
    const before = logo;
    setLogo(url);
    try {
      await update.mutateAsync({ community, patch: { profileImageUrl: url } });
    } catch {
      setLogo(before);
      toast.error(
        t({
          id: "somethingWentWrongTryAgain",
          message: "Something went wrong. Please try again.",
        }),
      );
    }
  };

  const divider = <Divider sx={{ borderColor: colors.onPrimaryContainer }} />;
  return (
    <Box>
      <Section
        label={t({ id: "basicInformation", message: "Basic Information" })}
      >
        <Box sx={{ display: "flex", flexDirection: "column", gap: "24px" }}>
          <TextField
            label={`${t({ id: "communityName", message: "Community Name" })}*`}
            value={draft.name}
            onChange={(event) =>
              set(FIELD.name, filterCommunityName(event.target.value))
            }
            error={!!nameError}
            helperText={
              nameError ?? `*${t({ id: "required", message: "Required" })}`
            }
            slotProps={{ htmlInput: { maxLength: NAME_MAX_LENGTH } }}
          />
          <TextField
            label={t({ id: "communityUrl", message: "Community URL" })}
            value={draft.displayId}
            onChange={(event) =>
              set(FIELD.displayId, filterDisplayId(event.target.value))
            }
            error={!!displayIdError}
            helperText={
              displayIdError ??
              `${window.location.origin}/space/${draft.displayId}`
            }
            slotProps={{ htmlInput: { maxLength: DISPLAY_ID_MAX_LENGTH } }}
          />
          <TextField
            label={t({ id: "communityTagline", message: "Community Tagline" })}
            value={draft.tagLine}
            onChange={(event) => set(FIELD.tagLine, event.target.value)}
            helperText={`${draft.tagLine.length}/${TAGLINE_MAX_LENGTH}`}
            slotProps={{ htmlInput: { maxLength: TAGLINE_MAX_LENGTH } }}
          />
          <TextField
            multiline
            minRows={3}
            label={t({
              id: "communityDescription",
              message: "Community Description",
            })}
            placeholder={t({
              id: "communityDescriptionHint",
              message: "Add more detail as to the goals of this community",
            })}
            value={draft.description}
            onChange={(event) => set(FIELD.description, event.target.value)}
          />
          <TextField
            type="email"
            label={t({ id: "email", message: "Email" })}
            placeholder={EXAMPLE_EMAIL}
            value={draft.contactEmail}
            onChange={(event) => set(FIELD.contactEmail, event.target.value)}
            error={!!emailError}
            helperText={emailError}
          />
        </Box>
      </Section>
      {divider}
      <Section label={t({ id: "links", message: "Links" })}>
        <Box sx={{ display: "flex", flexDirection: "column", gap: "24px" }}>
          {COMMUNITY_LINK_FIELDS.map((field) => {
            const error = linkError(field, platformNames(field));
            return (
              <TextField
                key={field}
                type="url"
                label={platformNames(field)}
                placeholder={EXAMPLE_ADDRESSES[field]}
                value={draft.links[field]}
                onChange={(event) => setLink(field, event.target.value)}
                error={!!error}
                helperText={error}
              />
            );
          })}
        </Box>
      </Section>
      {divider}
      <Section
        label={t({ id: "brandingAndTheme", message: "Branding & Theme" })}
      >
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            gap: "30px",
            pt: "15px",
          }}
        >
          <LogoField
            image={logo}
            onUpload={saveLogo}
            onRemove={() => saveLogo(placeholderLogo(community.id))}
          />
          <ThemeColorSection
            value={{ light: draft.light, dark: draft.dark }}
            onChange={({ light, dark }) => {
              setDraft((current) => ({ ...current, light, dark }));
            }}
          />
        </Box>
      </Section>
      <Box
        sx={{
          position: "sticky",
          bottom: 20,
          display: "flex",
          justifyContent: "flex-end",
          pt: "20px",
        }}
      >
        <ActionButton onPress={save}>
          {t({ id: "save", message: "Save" })}
        </ActionButton>
      </Box>
      {dialog}
    </Box>
  );
}
