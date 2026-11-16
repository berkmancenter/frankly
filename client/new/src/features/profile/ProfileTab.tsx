import EditIcon from "@mui/icons-material/Edit";
import Autocomplete from "@mui/material/Autocomplete";
import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import Chip from "@mui/material/Chip";
import TextField from "@mui/material/TextField";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import { SOCIAL_PLATFORMS, type PublicUser, type SocialPlatform } from "@/api/types";
import { ActionButton } from "@/components/ActionButton";
import { AppDialog } from "@/components/AppDialog";
import { Avatar } from "@/components/Avatar";
import { ErrorState, LoadingState } from "@/components/States";
import { useToast } from "@/components/Toast";
import { Upload } from "@/components/Upload";
import { useMe } from "@/queries/me";
import { useUpdateProfile } from "@/queries/profile";
import { useProfileTagMutations, useTagSuggestions, useUserTags } from "@/queries/tags";
import { colors } from "@/theme/tokens";
import { ProfileDrawer } from "./ProfileDrawer";

const AVATAR_SIZE = 160;

type Links = Record<SocialPlatform, string>;

const linksOf = (user: PublicUser): Links => {
  const links = Object.fromEntries(SOCIAL_PLATFORMS.map((platform) => [platform, ""])) as Links;
  for (const link of user.socialLinks ?? []) links[link.platform] = link.url;
  return links;
};

// The profile tab: the user's own picture, name, about text and social links, editable.
export function ProfileTab() {
  const { t } = useLingui();
  const me = useMe();
  if (me.isPending) return <LoadingState height={300} />;
  if (me.isError) {
    return (
      <ErrorState
        message={t({
          id: "errorLoadingProfileInfo",
          message: "There was an error loading profile info.",
        })}
      />
    );
  }
  return <ProfileForm key={me.data.user.id} user={me.data.user} />;
}

function ProfileForm({ user }: { user: PublicUser }) {
  const { t } = useLingui();
  const toast = useToast();
  const update = useUpdateProfile();
  const [name, setName] = useState(user.displayName);
  const [about, setAbout] = useState(user.about ?? "");
  const [links, setLinks] = useState<Links>(() => linksOf(user));
  const [uploading, setUploading] = useState(false);
  const [previewing, setPreviewing] = useState(false);

  const saved = linksOf(user);
  const dirty =
    name !== user.displayName ||
    about !== (user.about ?? "") ||
    SOCIAL_PLATFORMS.some((platform) => links[platform].trim() !== saved[platform]);
  const labels: Record<SocialPlatform, string> = {
    instagram: t({ id: "socialInstagram", message: "Instagram URL" }),
    twitter: t({ id: "socialTwitter", message: "Twitter URL" }),
    facebook: t({ id: "socialFacebook", message: "Facebook URL" }),
    linkedin: t({ id: "socialLinkedIn", message: "LinkedIn URL" }),
  };

  const run = async (patch: Parameters<typeof update.mutateAsync>[0]) => {
    try {
      await update.mutateAsync(patch);
      return true;
    } catch {
      toast.error(t`Something went wrong. Please try again.`);
      return false;
    }
  };

  const save = async () => {
    const saved = await run({
      displayName: name.trim(),
      about,
      socialLinks: SOCIAL_PLATFORMS.flatMap((platform) =>
        links[platform].trim() ? [{ platform, url: links[platform].trim() }] : [],
      ),
    });
    if (saved) toast.success(t({ id: "profileUpdated", message: "Profile updated" }));
  };

  return (
    <Box sx={{ width: "100%", maxWidth: 600, pt: "20px", display: "flex", flexDirection: "column", gap: "20px" }}>
      <Box sx={{ display: "flex", alignItems: "center", gap: "20px" }}>
        <ButtonBase
          aria-label={t`Change picture`}
          onClick={() => setUploading(true)}
          sx={{ position: "relative", borderRadius: "50%", flexShrink: 0 }}
        >
          <Avatar name={user.displayName} imageUrl={user.imageUrl} size={AVATAR_SIZE} ring={false} />
          <Box
            aria-hidden
            sx={{
              position: "absolute",
              right: 8,
              bottom: 8,
              width: 32,
              height: 32,
              borderRadius: "50%",
              bgcolor: colors.surfaceContainerLowest,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              boxShadow: 1,
            }}
          >
            <EditIcon sx={{ fontSize: 18, color: "primary.main" }} />
          </Box>
        </ButtonBase>
        <TextField
          fullWidth
          label={t({ id: "name", message: "Name" })}
          value={name}
          onChange={(event) => setName(event.target.value)}
          error={!name.trim()}
        />
      </Box>
      <TextField
        multiline
        fullWidth
        minRows={6}
        maxRows={6}
        label={t({ id: "aboutMe", message: "About me" })}
        value={about}
        onChange={(event) => setAbout(event.target.value)}
      />
      <TagsEditor userId={user.id} />
      {SOCIAL_PLATFORMS.map((platform) => (
        <TextField
          key={platform}
          fullWidth
          label={labels[platform]}
          value={links[platform]}
          onChange={(event) => setLinks({ ...links, [platform]: event.target.value })}
        />
      ))}
      <Box sx={{ display: "flex", justifyContent: "space-between", gap: "10px" }}>
        <ActionButton type="outline" onPress={() => setPreviewing(true)}>
          {t({ id: "preview", message: "Preview" })}
        </ActionButton>
        <ActionButton onPress={dirty && name.trim() ? save : undefined}>
          {t({ id: "updateProfile", message: "Update Profile" })}
        </ActionButton>
      </Box>

      <AppDialog
        open={uploading}
        onClose={() => setUploading(false)}
        maxWidth={500}
        padding={30}
        ariaLabel={t`Upload image`}
      >
        <Box sx={{ pt: "20px" }}>
          <Upload
            onUploaded={async ({ url }) => {
              setUploading(false);
              await run({ imageUrl: url });
            }}
          />
        </Box>
      </AppDialog>
      {previewing && <ProfileDrawer userId={user.id} onClose={() => setPreviewing(false)} />}
    </Box>
  );
}

// The profile's tags: removing one or adding one (typed, or picked from existing tags) saves at once.
function TagsEditor({ userId }: { userId: string }) {
  const { t } = useLingui();
  const toast = useToast();
  const tags = useUserTags(userId).data ?? [];
  const { add, remove } = useProfileTagMutations(userId);
  const [input, setInput] = useState("");
  const suggestions = useTagSuggestions(input).data ?? [];

  const fail = () => toast.error(t`Something went wrong. Please try again.`);
  const addTag = (raw: string) => {
    const title = raw.trim().replace(/^#+/, "").trim();
    setInput("");
    if (!title || tags.some((tag) => tag.title.toLowerCase() === title.toLowerCase())) return;
    add.mutate(title, { onError: fail });
  };

  return (
    <Box>
      <Box sx={{ display: "flex", flexWrap: "wrap", gap: "4px", mb: tags.length ? "10px" : 0 }}>
        {tags.map((tag) => (
          <Chip
            key={tag.id}
            label={`#${tag.title}`}
            onDelete={() => remove.mutate(tag.id, { onError: fail })}
          />
        ))}
      </Box>
      <Autocomplete
        freeSolo
        clearOnBlur={false}
        options={suggestions.map((tag) => tag.title)}
        filterOptions={(options) => options}
        inputValue={input}
        onInputChange={(_event, value, reason) => reason !== "reset" && setInput(value)}
        onChange={(_event, value) => typeof value === "string" && addTag(value)}
        renderInput={(params) => (
          <TextField {...params} label={t({ id: "addATag", message: "Add a tag" })} />
        )}
      />
    </Box>
  );
}
