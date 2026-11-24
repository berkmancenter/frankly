/** Branding that reads from `VITE_*` variables. */
// eslint-disable-next-line lingui/no-unlocalized-strings
export const appName: string = import.meta.env.VITE_APP_NAME || "Frankly";
export const supportEmail: string = import.meta.env.VITE_SUPPORT_EMAIL || "";
export const termsUrl: string = import.meta.env.VITE_TERMS_URL || "";

// Developer switches in the event settings: always outside production builds, and on a deployed
// test environment when `VITE_ENABLE_DEV_EVENT_SETTINGS=true`.
export const enableDevEventSettings = (): boolean =>
  import.meta.env.NODE_ENV !== "production" ||
  import.meta.env.VITE_ENABLE_DEV_EVENT_SETTINGS === "true";

// The same for the developer switches in the community's admin settings.
export const enableDevAdminSettings = (): boolean =>
  import.meta.env.NODE_ENV !== "production" ||
  import.meta.env.VITE_ENABLE_DEV_ADMIN_SETTINGS === "true";

/** Developer-only features when the app is served from `localhost`. */
export const isLocalhost = (): boolean =>
  window.location.hostname === "localhost";
