import {
  COMMUNITY_LINK_FIELDS,
  type Community,
  type CommunityLinkField,
} from "@/api/types";

/* eslint-disable lingui/no-unlocalized-strings -- field names, brand names and example addresses are not UI text */
export const FIELD = {
  name: "name",
  displayId: "displayId",
  tagLine: "tagLine",
  description: "description",
  contactEmail: "contactEmail",
} as const;

export const BRAND_NAMES: Record<CommunityLinkField, string | null> = {
  websiteUrl: null,
  blueskyUrl: "Bluesky",
  facebookUrl: "Facebook",
  linkedinUrl: "LinkedIn",
  twitterUrl: "X",
  youtubeUrl: "Youtube",
  instagramUrl: "Instagram",
};

export const EXAMPLE_ADDRESSES: Record<CommunityLinkField, string> = {
  websiteUrl: "https://yourwebsite.com",
  blueskyUrl: "bsky.app/profile/yourhandle",
  facebookUrl: "facebook.com/yourpage",
  linkedinUrl: "linkedin.com/in/yourprofile",
  twitterUrl: "x.com/yourhandle",
  youtubeUrl: "youtube.com/yourchannel",
  instagramUrl: "instagram.com/yourhandle",
};

export const EXAMPLE_EMAIL = "contact@yourdomain.com";
/* eslint-enable lingui/no-unlocalized-strings */

export const NAME_MAX_LENGTH = 80;
export const DISPLAY_ID_MAX_LENGTH = 80;
export const TAGLINE_MAX_LENGTH = 100;

export type LinkValues = Record<CommunityLinkField, string>;

export interface ProfileDraft {
  name: string;
  displayId: string;
  tagLine: string;
  description: string;
  contactEmail: string;
  links: LinkValues;
  light: string;
  dark: string;
}

export const draftOf = (community: Community): ProfileDraft => ({
  name: community.name,
  displayId: community.displayId,
  tagLine: community.tagLine ?? "",
  description: community.description ?? "",
  contactEmail: community.contactEmail ?? "",
  links: Object.fromEntries(
    COMMUNITY_LINK_FIELDS.map((field) => [field, community[field] ?? ""]),
  ) as LinkValues,
  light: community.themeLightColor ?? "",
  dark: community.themeDarkColor ?? "",
});

const WEBSITE = /^https?:\/\/[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(\/.*)?$/;
const EMAIL = /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/;
const DISPLAY_ID = /^[a-zA-Z0-9-]*$/;

/** What a social link has to contain, so a pasted profile URL is for the right site. */
/* eslint-disable lingui/no-unlocalized-strings -- host names, not UI text */
export const LINK_HOSTS: Record<
  Exclude<CommunityLinkField, "websiteUrl">,
  string
> = {
  blueskyUrl: "bsky.app",
  facebookUrl: "facebook.com",
  linkedinUrl: "linkedin.com",
  twitterUrl: "x.com",
  youtubeUrl: "youtube.com",
  instagramUrl: "instagram.com",
};
/* eslint-enable lingui/no-unlocalized-strings */

export type LinkProblem = { kind: "website" } | { kind: "host"; host: string };

/** Empty links are fine; a filled one must look like the right kind of address. */
export function linkProblem(
  field: CommunityLinkField,
  value: string,
): LinkProblem | undefined {
  if (!value) return undefined;
  if (field === "websiteUrl")
    return WEBSITE.test(value) ? undefined : { kind: "website" };
  const host = LINK_HOSTS[field];
  return value.includes(host) ? undefined : { kind: "host", host };
}

export const isEmailValid = (value: string) => !value || EMAIL.test(value);
export const isDisplayIdValid = (value: string) => DISPLAY_ID.test(value);

/** A stable number for a seed string, for picsum.photos placeholders. */
export function seedOf(text: string): number {
  let hash = 0;
  for (const char of text) hash = (hash * 31 + char.charCodeAt(0)) | 0;
  return Math.abs(hash);
}

export const placeholderLogo = (communityId: string) =>
  `https://picsum.photos/seed/${seedOf(communityId)}/160`;
