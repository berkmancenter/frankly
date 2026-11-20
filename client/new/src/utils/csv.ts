// Quotes a field when it holds a comma, a quote or a line break, like any spreadsheet app expects.
function field(value: unknown): string {
  const text = value === null || value === undefined ? "" : String(value);
  return /[",\r\n]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
}

export function toCsv(rows: readonly (readonly unknown[])[]): string {
  return rows.map((row) => row.map(field).join(",")).join("\r\n");
}

// Saves `content` through the browser, as if the person clicked a download link.
/* eslint-disable lingui/no-unlocalized-strings -- a media type and file markup, not UI text */
export function downloadText(
  fileName: string,
  content: string,
  mime = "text/csv;charset=utf-8",
): void {
  const url = URL.createObjectURL(new Blob([content], { type: mime }));
  const link = document.createElement("a");
  link.href = url;
  link.download = fileName;
  document.body.append(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}
/* eslint-enable lingui/no-unlocalized-strings */
