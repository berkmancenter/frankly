import { i18n } from "@lingui/core";

export const locales = {
  en: "English",
  es: "Español",
  zh: "中文",
  "zh-Hant-TW": "繁體中文",
};
export const defaultLocale = "en";

/**
 * Do a dynamic import of just the catalog that we need
 * @param locale any locale string
 */
export async function dynamicActivate(locale: string) {
  const { messages } = await import(`../locales/${locale}/messages.po`);
  i18n.load(locale, messages);
  i18n.activate(locale);
}
