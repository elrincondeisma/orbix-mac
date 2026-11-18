// Latest published version, read from GitHub at build time so the download button always
// points at the newest signed and notarized dmg. Offline, it falls back to the repo's VERSION.
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const REPO = "elrincondeisma/orbix-mac";

export interface Release {
  version: string;
  dmgUrl: string;
  releasesUrl: string;
  repoUrl: string;
}

function localVersion(): string {
  try {
    return readFileSync(resolve(process.cwd(), "../VERSION"), "utf8").trim();
  } catch {
    return "0.2.8";
  }
}

async function fetchRelease(): Promise<Release> {
  let version = localVersion();
  try {
    const response = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`, {
      headers: { Accept: "application/vnd.github+json" },
      signal: AbortSignal.timeout(5000),
    });
    if (response.ok) {
      const data = (await response.json()) as { tag_name?: string };
      version = data.tag_name?.replace(/^v/, "") || version;
    }
  } catch {
    // Offline build: keep the local version.
  }
  return {
    version,
    dmgUrl: `https://github.com/${REPO}/releases/download/v${version}/Orbix-${version}.dmg`,
    releasesUrl: `https://github.com/${REPO}/releases/latest`,
    repoUrl: `https://github.com/${REPO}`,
  };
}

// One request per build, shared by every language.
let cached: Promise<Release> | undefined;
export function latestRelease(): Promise<Release> {
  cached ??= fetchRelease();
  return cached;
}

export function fill(text: string, values: Record<string, string>): string {
  return text.replace(/\{(\w+)\}/g, (match, key: string) => values[key] ?? match);
}
