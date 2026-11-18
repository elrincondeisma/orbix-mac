import en from "./en";
import es from "./es";
import fr from "./fr";
import de from "./de";
import pt from "./pt";

export type Dict = typeof en;

export const locales = ["en", "es", "fr", "de", "pt"] as const;
export type Locale = (typeof locales)[number];
export const defaultLocale: Locale = "en";

/** Everything the page needs to know about a language, besides its words. */
export const localeInfo: Record<Locale, { name: string; short: string; hreflang: string; og: string; intl: string }> = {
  en: { name: "English", short: "EN", hreflang: "en", og: "en_US", intl: "en-US" },
  es: { name: "Español", short: "ES", hreflang: "es", og: "es_ES", intl: "es-ES" },
  fr: { name: "Français", short: "FR", hreflang: "fr", og: "fr_FR", intl: "fr-FR" },
  de: { name: "Deutsch", short: "DE", hreflang: "de", og: "de_DE", intl: "de-DE" },
  pt: { name: "Português", short: "PT", hreflang: "pt-BR", og: "pt_BR", intl: "pt-BR" },
};

const dictionaries: Record<Locale, Dict> = { en, es, fr, de, pt };

export function t(locale: Locale): Dict {
  return dictionaries[locale];
}

/** Home page path for a language: "/" for English, "/es/" for Spanish. */
export function homePath(locale: Locale): string {
  return locale === defaultLocale ? "/" : `/${locale}/`;
}
