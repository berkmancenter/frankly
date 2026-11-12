/** Longest name or URL slug the create form accepts. */
export const COMMUNITY_FIELD_MAX_LENGTH = 80;

/** Characters allowed in a community name: letters, digits, `_` and whitespace. */
export function filterCommunityName(value: string): string {
  return value.replace(/[^\s\w]/g, "");
}

/** The URL slug suggested by a community name */
export function displayIdFromName(name: string): string {
  return name
    .replace(/[^a-zA-Z0-9\-_]/g, "-")
    .replace(/--+/g, "-")
    .replace(/-+$/, "-")
    .toLowerCase();
}

/** A hand-typed URL slug keeps only lowercase letters, digits, `-` and `+`. */
export function filterDisplayId(value: string): string {
  return value.toLowerCase().replace(/[^0-9a-z\-+]/g, "");
}
