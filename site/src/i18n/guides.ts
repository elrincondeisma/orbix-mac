// Words and paths for the guides, which exist in English and Spanish only.
import type { Locale } from "./config";

export const guideLocales = ["en", "es"] as const;
export type GuideLocale = (typeof guideLocales)[number];

export function hasGuides(locale: Locale): locale is GuideLocale {
  return (guideLocales as readonly string[]).includes(locale);
}

export const guidesBase: Record<GuideLocale, string> = {
  en: "/guides/",
  es: "/es/guias/",
};

export const guideWords: Record<
  GuideLocale,
  {
    nav: string;
    indexTitle: string;
    indexSeoTitle: string;
    indexDescription: string;
    indexLede: string;
    breadcrumb: string;
    updated: string;
    related: string;
    ctaTitle: string;
    ctaText: string;
    ctaButton: string;
    read: string;
  }
> = {
  en: {
    nav: "Guides",
    indexTitle: "Guides to Claude Code usage",
    indexSeoTitle: "Claude Code usage guides: limits, accounts and API cost",
    indexDescription:
      "How to check your Claude Code usage, how the 5-hour and weekly limits work, how to use several accounts on one Mac and what your usage would cost on the API.",
    indexLede:
      "How Claude's limits work and how to keep an eye on them, with the exact commands. Written by the maker of Orbix and checked against Anthropic's documentation.",
    breadcrumb: "Guides",
    updated: "Updated",
    related: "More guides",
    ctaTitle: "See it without opening a terminal",
    ctaText: "Orbix keeps your session and weekly limits in the Mac menu bar, with the time each one resets. Free, for macOS 14 or later.",
    ctaButton: "Download Orbix",
    read: "Read the guide",
  },
  es: {
    nav: "Guías",
    indexTitle: "Guías sobre el uso de Claude Code",
    indexSeoTitle: "Guías de Claude Code: límites, varias cuentas y coste en API",
    indexDescription:
      "Cómo ver tu uso de Claude Code, cómo funcionan los límites de 5 horas y semanal, cómo usar varias cuentas en un Mac y cuánto costaría tu uso por API.",
    indexLede:
      "Cómo funcionan los límites de Claude y cómo tenerlos vigilados, con los comandos exactos. Escritas por el autor de Orbix y contrastadas con la documentación de Anthropic.",
    breadcrumb: "Guías",
    updated: "Actualizada",
    related: "Más guías",
    ctaTitle: "Míralo sin abrir la terminal",
    ctaText: "Orbix deja tu sesión y tus límites semanales en la barra de menús del Mac, con la hora a la que se reinicia cada uno. Gratis, para macOS 14 o posterior.",
    ctaButton: "Descargar Orbix",
    read: "Leer la guía",
  },
};
