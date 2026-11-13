import { i18n } from "@lingui/core";

export const locales = {
  en: "English",
  es: "Español",
  zh: "中文",
  "zh-Hant-TW": "繁體中文",
};
export const defaultLocale = "en";

// `I18nProvider` renders nothing until a locale is active, which would hide the root layout's
// loading indicator while the real catalog downloads. Activate an empty catalog right away;
// `RootLayout` holds back the app until `dynamicActivate` has loaded the real one.
i18n.loadAndActivate({ locale: defaultLocale, messages: {} });

/**
 * Do a dynamic import of just the catalog that we need
 * @param locale any locale string
 */
export async function dynamicActivate(locale: string) {
  const { messages } = await import(`../locales/${locale}/messages.po`);
  i18n.load(locale, messages);
  i18n.activate(locale);
}
