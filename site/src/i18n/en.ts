// English, the default language. Every other dictionary has this exact shape.
// "{version}" is replaced with the latest release number at build time.
export default {
  meta: {
    title: "Orbix: Claude Code usage limits in your Mac menu bar",
    description:
      "Free Mac menu bar app for Claude Code: see what's left of your 5-hour session and weekly limit, when each resets and what it would cost on the API.",
    ogAlt: "Orbix: the usage ring in the Mac menu bar and its panel with the 5-hour session and weekly limits",
  },
  nav: {
    label: "Sections",
    session: "How it works",
    panel: "Panel",
    accounts: "Accounts",
    privacy: "Privacy",
    install: "Install",
    faq: "FAQ",
    download: "Download",
    language: "Language",
    openPanel: "Open the Orbix panel",
    home: "Orbix, home",
    skip: "Skip to content",
  },
  hero: {
    title: "See your Claude limit before you hit it.",
    lede: "Orbix is a free Mac menu bar app for Claude Code usage. It shows how much of the 5-hour session and the week you have left, when each one resets, and what that usage would cost on the API.",
    download: "Download for Mac",
    source: "View on GitHub",
    meta: "Version {version}, free. macOS 14 or later, Apple Silicon and Intel. Signed and notarized by Apple.",
  },
  ring: {
    label: "Five-hour session usage",
    used: "used",
    session: "5-hour session",
    weekly: "Weekly",
    now: "Now",
    resets: "Resets",
    reset: "New session",
  },
  session: {
    title: "One session, from first prompt to reset",
    steps: [
      {
        title: "70%, and the ring turns amber.",
        text: "There's room to finish what you're doing. Orbix shows exactly when the session resets, so you can decide whether to push on or wait.",
      },
      {
        title: "90%. Red means switch or pause.",
        text: "Move to another Claude Code account with one click, or come back after the reset. No more hitting the wall halfway through a task.",
      },
      {
        title: "Reset. Five fresh hours.",
        text: "The ring empties. The weekly limit keeps its own count, with its own reset day and time, right underneath.",
      },
    ],
  },
  tour: {
    title: "Everything else, one click away.",
    lede: "Click the menu bar icon and the panel opens. The compact view shows the session and your limits; the full view adds the rest. Point at a section to find it in the panel.",
    alt: "The full Orbix panel: session, weekly limits, accounts, unused extras, API cost, activity and models",
    note: "",
    regions: [
      { title: "The 5-hour session", text: "How much of the current window is left and when it resets. The ring turns amber near the limit." },
      { title: "Weekly limits", text: "The overall limit and the per-model ones, each with its reset day and time." },
      { title: "Your accounts", text: "Every Claude Code profile with its own session and week. Turn one on and the next claude uses it." },
      { title: "Unused extras", text: "Free resets you've saved, prepaid balance and this month's extra usage, read from claude.ai." },
      { title: "What it would cost on the API", text: "The current session and the last 30 days at list prices, worked out from your local sessions." },
      { title: "Activity", text: "Tokens per day, responses and sessions in Claude Code over the last week." },
      { title: "Models you use", text: "Which models you lean on, with their tokens and their API cost." },
    ],
  },
  accounts: {
    title: "Several accounts, one switch.",
    body: [
      "Each Claude Code account lives in its own profile, with its own login, history and MCP servers. Your settings, instructions and skills are shared.",
      "Turn one on in Orbix and the next claude you open signs in with it, in Terminal, in VS Code or in herdr panes. Long-lived tokens work too, and stay in your Keychain.",
    ],
    try: "Try the switches",
    cardTitle: "Accounts",
    session: "session",
    week: "week",
    noLimits: "no limits",
    rows: [
      { name: "Main", kind: "login", session: 26, week: 48 },
      { name: "Work", kind: "login", session: 71, week: 83 },
      { name: "CI pipeline", kind: "token", session: null, week: null },
    ],
    opensWith: "opens with",
    once: "another one, just this once",
    switch: "changes the active one",
    switchLabel: "Use {name}",
  },
  privacy: {
    title: "It reads your usage. Nothing else.",
    readsTitle: "What it reads",
    reads: [
      "The answer to claude /usage, without saving that session to your history.",
      "The token counts of your Claude Code sessions on this Mac, never what the conversations say.",
      "If you turn it on, your claude.ai browser session, for free resets and extra usage. macOS asks first.",
    ],
    neverTitle: "What it never does",
    never: [
      "Send anything to servers of its own. There are no accounts, analytics or telemetry.",
      "Touch your Claude Code logins. Each account is handled by Claude Code itself.",
      "Store tokens in files. The ones you paste go to your Keychain.",
    ],
  },
  install: {
    title: "Installing takes half a minute.",
    steps: [
      { title: "Download the .dmg", text: "Version {version}, signed and notarized." },
      { title: "Drag Orbix to Applications", text: "In the window that opens." },
      { title: "Open it", text: "It shows up in the menu bar, top right, and asks whether to open at login." },
    ],
    download: "Download Orbix {version}",
    note: "You need Claude Code installed and signed in.",
    allReleases: "All versions on GitHub",
    window: "Installer window: Orbix on the left, the Applications folder on the right",
    drag: "Drag Orbix to the Applications folder",
    applications: "Applications",
  },
  faq: {
    title: "Questions",
    items: [
      { q: "How much does it cost?", a: "Nothing. Orbix is free and its code is on GitHub." },
      {
        q: "What do I need?",
        a: "A Mac with macOS 14 or later, and Claude Code installed and signed in. Orbix asks claude for your limits, so you don't paste any key.",
      },
      {
        q: "Does it work with Pro, Max, Team or Enterprise?",
        a: "With any subscription plan that shows limits in claude /usage. On plans without a 5-hour limit, it follows the weekly one. If your organization has no limits, Orbix still shows activity and the equivalent cost.",
      },
      {
        q: "What language is the app in?",
        a: "English and Spanish. It follows your Mac's language: Spanish if your Mac is set to Spanish, English for any other language.",
      },
      {
        q: "Why doesn't an account with a token show limits?",
        a: "Long-lived tokens from claude setup-token only let you use the model; Claude Code doesn't report their limits. Orbix says so on that account and keeps showing its activity.",
      },
      {
        q: "Does it open when I start my Mac?",
        a: "If you want. The first time it asks whether to open at login, and you can change it any time in its settings or in System Settings, General, Login Items. It never adds itself without asking.",
      },
      {
        q: "How does it update?",
        a: "On its own. Once a day it checks for a new version, downloads it, verifies its signature and restarts. You can also check from its settings.",
      },
      {
        q: "Is it an official Anthropic app?",
        a: "No. Orbix is an independent project and isn't affiliated with Anthropic. Claude and Claude Code are trademarks of Anthropic.",
      },
    ],
  },
  footer: {
    madeBy: "Made by",
    legal: "Orbix isn't affiliated with Anthropic. Claude is a trademark of Anthropic.",
    site: "This site has no cookies and no analytics.",
    source: "Source code",
    languages: "Languages",
  },
};
