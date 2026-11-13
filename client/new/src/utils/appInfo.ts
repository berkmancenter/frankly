/** Branding that reads from `VITE_*` variables. */
// eslint-disable-next-line lingui/no-unlocalized-strings
export const appName: string = import.meta.env.VITE_APP_NAME || "Frankly";
export const supportEmail: string = import.meta.env.VITE_SUPPORT_EMAIL || "";
export const termsUrl: string = import.meta.env.VITE_TERMS_URL || "";

/** Developer-only features when the app is served from `localhost`. */
export const isLocalhost = (): boolean =>
  window.location.hostname === "localhost";
