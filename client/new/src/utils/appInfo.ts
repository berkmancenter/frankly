/** Branding that Flutter reads from `Environment`; here from `VITE_*` variables. */
export const appName: string = import.meta.env.VITE_APP_NAME || "Frankly";
export const supportEmail: string = import.meta.env.VITE_SUPPORT_EMAIL || "";
export const termsUrl: string = import.meta.env.VITE_TERMS_URL || "";
