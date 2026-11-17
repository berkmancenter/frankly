// A user-typed link made safe to open: http(s) only, and a bare "example.com" gets https.
export function webUrl(raw: string): string | undefined {
  const text = raw.trim();
  if (!text) return undefined;
  try {
    const url = new URL(/^[a-z][a-z\d+.-]*:/i.test(text) ? text : `https://${text}`);
    return url.protocol === "https:" || url.protocol === "http:" ? url.href : undefined;
  } catch {
    return undefined;
  }
}
