import { defineCollection } from "astro:content";
import { glob } from "astro/loaders";
import { z } from "astro/zod";

// Guides live in src/content/guides/<locale>/<file>.md. The same `key` joins the versions of
// one guide across languages; `urlSlug` is its URL in that language (not `slug`, which the loader would take as the entry id).
const guides = defineCollection({
  loader: glob({ pattern: "**/*.md", base: "./src/content/guides" }),
  schema: z.object({
    key: z.string(),
    urlSlug: z.string(),
    title: z.string(),
    seoTitle: z.string(),
    description: z.string().max(160),
    order: z.number(),
    published: z.coerce.date(),
    updated: z.coerce.date(),
  }),
});

export const collections = { guides };
