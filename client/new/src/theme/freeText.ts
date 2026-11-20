// Style values for text people typed: CSS keywords, not UI text.
/* eslint-disable lingui/no-unlocalized-strings */
// Long words and links never overflow their column.
export const wrapAnywhere = { overflowWrap: "anywhere" } as const;
// The same, and line breaks are kept.
export const freeText = { whiteSpace: "pre-wrap", overflowWrap: "anywhere" } as const;
