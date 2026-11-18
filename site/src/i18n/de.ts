import type { Dict } from "./config";

const de: Dict = {
  meta: {
    title: "Orbix: Claude-Code-Limits in der Menüleiste des Mac",
    description:
      "Kostenlose Menüleisten-App für Claude Code: was von 5-Stunden-Sitzung und Wochenlimit übrig ist, wann beide neu starten und was es per API kosten würde.",
    ogAlt: "Orbix: der Nutzungsring in der Menüleiste des Mac und sein Panel mit 5-Stunden-Sitzung und Wochenlimits",
  },
  nav: {
    label: "Bereiche",
    session: "So funktioniert's",
    panel: "Panel",
    accounts: "Konten",
    privacy: "Datenschutz",
    install: "Installieren",
    faq: "Fragen",
    download: "Download",
    language: "Sprache",
    openPanel: "Orbix-Panel öffnen",
    home: "Orbix, Startseite",
    skip: "Zum Inhalt springen",
  },
  hero: {
    title: "Sehen Sie Ihr Claude-Limit, bevor Sie es erreichen.",
    lede: "Orbix ist eine kostenlose Menüleisten-App für die Nutzung von Claude Code. Sie zeigt, wie viel von der 5-Stunden-Sitzung und der Woche übrig ist, wann beide zurückgesetzt werden und was diese Nutzung über die API kosten würde.",
    download: "Für Mac herunterladen",
    source: "Auf GitHub ansehen",
    meta: "Version {version}, kostenlos. macOS 14 oder neuer, Apple Silicon und Intel. Von Apple signiert und notariell beglaubigt.",
  },
  ring: {
    label: "Nutzung der Fünf-Stunden-Sitzung",
    used: "genutzt",
    session: "5-Stunden-Sitzung",
    weekly: "Woche",
    now: "Jetzt",
    resets: "Neustart",
    reset: "Neue Sitzung",
  },
  session: {
    title: "Eine Sitzung, vom ersten Prompt bis zum Neustart",
    steps: [
      {
        title: "Bei 70 % wird der Ring bernsteinfarben.",
        text: "Es reicht noch, um fertig zu machen, woran Sie gerade sitzen. Orbix zeigt die genaue Uhrzeit des Neustarts, damit Sie entscheiden können: weitermachen oder warten.",
      },
      {
        title: "Bei 90 % heißt Rot: wechseln oder pausieren.",
        text: "Wechseln Sie mit einem Klick zu einem anderen Claude-Code-Konto oder machen Sie nach dem Neustart weiter. Nie mehr mitten in einer Aufgabe ans Limit stoßen.",
      },
      {
        title: "Neustart. Fünf frische Stunden.",
        text: "Der Ring leert sich. Das Wochenlimit zählt für sich weiter, mit eigenem Tag und eigener Uhrzeit für den Neustart, direkt darunter.",
      },
    ],
  },
  tour: {
    title: "Alles andere, einen Klick entfernt.",
    lede: "Ein Klick auf das Symbol in der Menüleiste öffnet das Panel. Die kompakte Ansicht zeigt Sitzung und Limits, die vollständige alles Weitere. Zeigen Sie auf einen Bereich, um ihn im Panel zu finden.",
    alt: "Das vollständige Orbix-Panel: Sitzung, Wochenlimits, Konten, ungenutzte Extras, API-Kosten, Aktivität und Modelle",
    note: "Die Oberfläche der App ist vorerst auf Spanisch.",
    regions: [
      { title: "Die 5-Stunden-Sitzung", text: "Wie viel vom aktuellen Zeitfenster übrig ist und wann es zurückgesetzt wird. Nahe am Limit wird der Ring bernsteinfarben." },
      { title: "Wochenlimits", text: "Das allgemeine Limit und die pro Modell, jeweils mit Tag und Uhrzeit des Neustarts." },
      { title: "Ihre Konten", text: "Jedes Claude-Code-Profil mit eigener Sitzung und Woche. Schalten Sie eines ein, und das nächste claude nutzt es." },
      { title: "Ungenutzte Extras", text: "Gespeicherte Gratis-Neustarts, Prepaid-Guthaben und Zusatznutzung des Monats, gelesen von claude.ai." },
      { title: "Was es über die API kosten würde", text: "Die aktuelle Sitzung und die letzten 30 Tage zu Listenpreisen, berechnet aus Ihren lokalen Sitzungen." },
      { title: "Aktivität", text: "Tokens pro Tag, Antworten und Sitzungen in Claude Code der letzten Woche." },
      { title: "Ihre Modelle", text: "Welche Modelle Sie am meisten nutzen, mit Tokens und API-Kosten." },
    ],
  },
  accounts: {
    title: "Mehrere Konten, ein Schalter.",
    body: [
      "Jedes Claude-Code-Konto lebt in einem eigenen Profil, mit eigenem Login, eigenem Verlauf und eigenen MCP-Servern. Einstellungen, Anweisungen und Skills werden geteilt.",
      "Schalten Sie eines in Orbix ein, und das nächste claude, das Sie öffnen, meldet sich damit an: im Terminal, in VS Code oder in herdr-Panes. Langlebige Tokens funktionieren auch und bleiben in Ihrem Schlüsselbund.",
    ],
    try: "Probieren Sie die Schalter",
    cardTitle: "Konten",
    session: "Sitzung",
    week: "Woche",
    noLimits: "ohne Limits",
    rows: [
      { name: "Privat", kind: "login", session: 26, week: 48 },
      { name: "Arbeit", kind: "login", session: 71, week: 83 },
      { name: "CI-Pipeline", kind: "token", session: null, week: null },
    ],
    opensWith: "startet mit",
    once: "ein anderes, nur dieses Mal",
    switch: "wechselt das aktive",
    switchLabel: "{name} verwenden",
  },
  privacy: {
    title: "Es liest Ihre Nutzung. Sonst nichts.",
    readsTitle: "Was es liest",
    reads: [
      "Die Antwort von claude /usage, ohne diese Sitzung in Ihrem Verlauf zu speichern.",
      "Die Token-Zahlen Ihrer Claude-Code-Sitzungen auf diesem Mac, nie den Inhalt der Unterhaltungen.",
      "Wenn Sie es aktivieren, Ihre claude.ai-Sitzung im Browser, für Gratis-Neustarts und Zusatznutzung. macOS fragt vorher.",
    ],
    neverTitle: "Was es nie tut",
    never: [
      "Daten an eigene Server senden. Es gibt keine Konten, keine Analyse und keine Telemetrie.",
      "Ihre Claude-Code-Logins anfassen. Jedes Konto verwaltet Claude Code selbst.",
      "Tokens in Dateien speichern. Was Sie einfügen, landet in Ihrem Schlüsselbund.",
    ],
  },
  install: {
    title: "Die Installation dauert eine halbe Minute.",
    steps: [
      { title: "Laden Sie die .dmg herunter", text: "Version {version}, signiert und notariell beglaubigt." },
      { title: "Ziehen Sie Orbix in Programme", text: "Im Fenster, das sich öffnet." },
      { title: "Öffnen Sie es", text: "Es erscheint oben rechts in der Menüleiste und fragt, ob es beim Anmelden starten soll." },
    ],
    download: "Orbix {version} herunterladen",
    note: "Sie brauchen Claude Code, installiert und angemeldet.",
    allReleases: "Alle Versionen auf GitHub",
    window: "Installationsfenster: Orbix links, der Ordner Programme rechts",
    drag: "Ziehen Sie Orbix in den Ordner Programme",
    applications: "Programme",
  },
  faq: {
    title: "Fragen",
    items: [
      { q: "Was kostet es?", a: "Nichts. Orbix ist kostenlos, und der Code liegt auf GitHub." },
      {
        q: "Was brauche ich?",
        a: "Einen Mac mit macOS 14 oder neuer und Claude Code, installiert und angemeldet. Orbix fragt claude nach Ihren Limits, Sie müssen also keinen Schlüssel einfügen.",
      },
      {
        q: "Funktioniert es mit Pro, Max, Team oder Enterprise?",
        a: "Mit jedem Abo, das in claude /usage Limits anzeigt. Bei Tarifen ohne 5-Stunden-Limit folgt es dem Wochenlimit. Hat Ihre Organisation keine Limits, zeigt Orbix trotzdem Aktivität und die entsprechenden Kosten.",
      },
      {
        q: "In welcher Sprache ist die App?",
        a: "Vorerst auf Spanisch. Ringe, Farben und Zahlen lesen sich in jeder Sprache gleich.",
      },
      {
        q: "Warum zeigt ein Konto mit Token keine Limits?",
        a: "Langlebige Tokens aus claude setup-token dienen nur zur Nutzung des Modells; Claude Code meldet ihre Limits nicht. Orbix weist bei diesem Konto darauf hin und zeigt weiter seine Aktivität.",
      },
      {
        q: "Startet es mit dem Mac?",
        a: "Wenn Sie möchten. Beim ersten Mal fragt es, ob es beim Anmelden starten soll. Ändern können Sie das jederzeit in seinen Einstellungen oder in den Systemeinstellungen unter Allgemein, Anmeldeobjekte. Ungefragt trägt es sich nie ein.",
      },
      {
        q: "Wie wird es aktualisiert?",
        a: "Von selbst. Einmal am Tag sucht es nach einer neuen Version, lädt sie, prüft die Signatur und startet neu. Sie können auch in den Einstellungen danach suchen.",
      },
      {
        q: "Ist es eine offizielle App von Anthropic?",
        a: "Nein. Orbix ist ein unabhängiges Projekt und nicht mit Anthropic verbunden. Claude und Claude Code sind Marken von Anthropic.",
      },
    ],
  },
  footer: {
    madeBy: "Gemacht von",
    legal: "Orbix ist nicht mit Anthropic verbunden. Claude ist eine Marke von Anthropic.",
    site: "Diese Website verwendet keine Cookies und keine Analyse.",
    source: "Quellcode",
    languages: "Sprachen",
  },
};

export default de;
