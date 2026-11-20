export const isBlank = (s: string | null | undefined): boolean =>
  !s || s.trim().length === 0;

// `enableAVCheck` -> `Enable A/V Check`: a settings key as a label, for developer switches that have none.
/* eslint-disable lingui/no-unlocalized-strings -- turns identifiers into labels */
export function humanizeKey(key: string): string {
  const spaced = key.replace(/([A-Z])/g, " $1").trim();
  return (spaced.charAt(0).toUpperCase() + spaced.slice(1)).replace(
    "A V",
    "A/V",
  );
}
/* eslint-enable lingui/no-unlocalized-strings */
