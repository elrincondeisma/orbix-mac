# Orbix website

Landing page for Orbix at <https://orbix.elrincondeisma.com>, built with Astro as a static site.

```sh
npm install
npm run dev       # http://localhost:4321
npm run build     # static site in dist/
npx astro check   # type-check
```

## Languages

English lives at `/`; Spanish, French, German and Brazilian Portuguese at `/es/`, `/fr/`, `/de/`
and `/pt/`. All copy is in `src/i18n/<locale>.ts`, and every dictionary has the shape of
`en.ts` (TypeScript complains if one is missing a key).

To add a language: create `src/i18n/<code>.ts`, register it in `src/i18n/config.ts`
(`locales` and `localeInfo`) and in `astro.config.mjs` (`i18n.locales` and the sitemap), then
render its share image (below).

## Guides

Guides live in `src/content/guides/<locale>/<file>.md`, in English (`/guides/…`) and Spanish
(`/es/guias/…`). The frontmatter says what each one is:

```yaml
key: check-usage            # the same in every language: joins the translations (hreflang)
urlSlug: check-claude-code-usage
title: How to check your Claude Code usage
seoTitle: "How to check your Claude Code usage and limits: 3 ways"
description: "…"          # 160 characters at most; the build fails above that
order: 1
published: 2026-11-18
updated: 2026-11-18
```

Facts about Claude's limits come from Anthropic's help center and the Claude Code docs; link
the source when a guide relies on it. UI strings for the guides are in `src/i18n/guides.ts`.

## SEO

Each page has its own title, description, canonical URL, `hreflang` alternates (plus
`x-default`), Open Graph and Twitter tags, and JSON-LD for the app (`SoftwareApplication`) and
its FAQ (`FAQPage`). `@astrojs/sitemap` writes `sitemap-index.xml` with the language
alternates; `public/robots.txt` points at it.

The download link and version are read from the latest GitHub release at build time, with
`../VERSION` as the fallback when offline.

## Share images

`public/og/<locale>.png` (1200×630) are screenshots of `/og/<locale>/`, a page that isn't
linked, indexed or listed in the sitemap. After changing a headline, regenerate them:

```sh
npm run build && npx astro preview --port 4322 &
agent-browser set viewport 1200 630
for l in en es fr de pt; do
  agent-browser open http://localhost:4322/og/$l/ && agent-browser screenshot public/og/$l.png
done
```

## Structure

```
src/components/Landing.astro   The page, composed per language
src/components/MenuBar.astro   Header as a Mac menu bar: language menu, live status item, panel
src/components/Session.astro   Hero and the scroll-driven 5-hour session ring
src/components/Tour.astro      Full panel that scrolls to the section you point at
src/components/Accounts.astro  Working accounts switches and terminal
src/components/Shot.astro      Screenshot that follows light or dark appearance
src/components/GuidePage.astro One guide: article, call to action, related guides
src/components/GuideIndex.astro The list of guides in one language
src/components/Footer.astro    Footer shared by every page
src/content/guides/            Guides in Markdown, per language
src/layouts/Base.astro         <head>: meta, hreflang, Open Graph, JSON-LD
src/lib/release.ts             Latest release from GitHub
```

Fonts (Funnel Display and Funnel Sans) are self-hosted through Fontsource, so the site makes no
third-party requests.
