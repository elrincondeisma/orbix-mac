// Latest published version, read from GitHub at build time so the download button always
// points at the newest signed and notarized dmg.
const REPO = "elrincondeisma/orbix-mac";
const FALLBACK = "0.2.3";

export interface Release {
  version: string;
  dmgUrl: string;
  releasesUrl: string;
  repoUrl: string;
}

export async function latestRelease(): Promise<Release> {
  let version = FALLBACK;
  try {
    const response = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`, {
      headers: { Accept: "application/vnd.github+json" },
    });
    if (response.ok) {
      const data = (await response.json()) as { tag_name?: string };
      version = data.tag_name?.replace(/^v/, "") || FALLBACK;
    }
  } catch {
    // Offline build: keep the fallback version.
  }
  return {
    version,
    dmgUrl: `https://github.com/${REPO}/releases/download/v${version}/Orbix-${version}.dmg`,
    releasesUrl: `https://github.com/${REPO}/releases/latest`,
    repoUrl: `https://github.com/${REPO}`,
  };
}
