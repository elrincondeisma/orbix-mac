// @ts-check
import { defineConfig } from "astro/config";
import sitemap from "@astrojs/sitemap";

// English lives at the root; the other languages under their own prefix (/es/, /fr/…).
export default defineConfig({
  site: "https://orbix.elrincondeisma.com",
  trailingSlash: "always",
  i18n: {
    defaultLocale: "en",
    locales: ["en", "es", "fr", "de", "pt"],
    routing: { prefixDefaultLocale: false },
  },
  integrations: [
    sitemap({
      // The Open Graph card templates are only rendered to make the share images.
      filter: (page) => !page.includes("/og/"),
      i18n: {
        defaultLocale: "en",
        locales: { en: "en", es: "es", fr: "fr", de: "de", pt: "pt-BR" },
      },
    }),
  ],
});
