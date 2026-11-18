import type { Dict } from "./config";

const fr: Dict = {
  meta: {
    title: "Orbix : vos limites Claude Code dans la barre des menus du Mac",
    description:
      "App gratuite pour la barre des menus du Mac : ce qu'il reste de votre session de 5 heures et de la semaine Claude Code, et quand elles se réinitialisent.",
    ogAlt: "Orbix : l'anneau d'utilisation dans la barre des menus du Mac et son panneau avec la session de 5 heures et les limites hebdomadaires",
  },
  nav: {
    label: "Sections",
    session: "Fonctionnement",
    panel: "Panneau",
    accounts: "Comptes",
    privacy: "Confidentialité",
    install: "Installer",
    faq: "Questions",
    download: "Télécharger",
    language: "Langue",
    openPanel: "Ouvrir le panneau d'Orbix",
    home: "Orbix, accueil",
    skip: "Aller au contenu",
  },
  hero: {
    title: "Voyez votre limite Claude avant de l'atteindre.",
    lede: "Orbix affiche gratuitement l'utilisation de Claude Code dans la barre des menus du Mac. Il indique ce qu'il vous reste de la session de 5 heures et de la semaine, quand chacune se réinitialise et ce que cet usage coûterait via l'API.",
    download: "Télécharger pour Mac",
    source: "Voir sur GitHub",
    meta: "Version {version}, gratuite. macOS 14 ou ultérieur, Apple Silicon et Intel. Signée et notarisée par Apple.",
  },
  ring: {
    label: "Utilisation de la session de cinq heures",
    used: "utilisé",
    session: "Session de 5 h",
    weekly: "Semaine",
    now: "Maintenant",
    resets: "Remise à zéro",
    reset: "Nouvelle session",
  },
  session: {
    title: "Une session, du premier prompt à la remise à zéro",
    steps: [
      {
        title: "À 70 %, l'anneau passe à l'ambre.",
        text: "Vous avez de quoi finir ce que vous faites. Orbix affiche l'heure exacte de la remise à zéro, pour décider s'il vaut mieux continuer ou attendre.",
      },
      {
        title: "À 90 %, le rouge dit : changez ou faites une pause.",
        text: "Passez à un autre compte Claude Code en un clic, ou revenez après la remise à zéro. Fini de buter sur la limite au milieu d'une tâche.",
      },
      {
        title: "Remise à zéro. Cinq heures neuves.",
        text: "L'anneau se vide. La limite hebdomadaire garde son propre compte, avec son jour et son heure de remise à zéro, juste en dessous.",
      },
    ],
  },
  tour: {
    title: "Tout le reste, en un clic.",
    lede: "Un clic sur l'icône de la barre des menus et le panneau s'ouvre. La vue compacte montre la session et vos limites ; la vue complète ajoute le reste. Survolez une section pour la retrouver dans le panneau.",
    alt: "Le panneau complet d'Orbix : session, limites hebdomadaires, comptes, extras inutilisés, coût API, activité et modèles",
    note: "",
    regions: [
      { title: "La session de 5 heures", text: "Ce qu'il reste de la fenêtre en cours et quand elle se réinitialise. L'anneau passe à l'ambre près de la limite." },
      { title: "Les limites hebdomadaires", text: "La limite générale et celles de chaque modèle, avec leur jour et leur heure de remise à zéro." },
      { title: "Vos comptes", text: "Chaque profil Claude Code avec sa session et sa semaine. Activez-en un et le prochain claude l'utilise." },
      { title: "Les extras inutilisés", text: "Remises à zéro gratuites en réserve, solde prépayé et usage supplémentaire du mois, lus sur claude.ai." },
      { title: "Ce que coûterait l'API", text: "La session en cours et les 30 derniers jours au prix catalogue, calculés à partir de vos sessions locales." },
      { title: "Activité", text: "Tokens par jour, réponses et sessions dans Claude Code sur la dernière semaine." },
      { title: "Vos modèles", text: "Les modèles sur lesquels vous comptez, avec leurs tokens et leur coût API." },
    ],
  },
  accounts: {
    title: "Plusieurs comptes, un interrupteur.",
    body: [
      "Chaque compte Claude Code vit dans son propre profil, avec sa connexion, son historique et ses serveurs MCP. Vos réglages, instructions et skills sont partagés.",
      "Activez-en un dans Orbix et le prochain claude que vous ouvrez s'y connecte, dans le Terminal, dans VS Code ou dans les panneaux de herdr. Les tokens longue durée fonctionnent aussi et restent dans votre Trousseau.",
    ],
    try: "Essayez les interrupteurs",
    cardTitle: "Comptes",
    session: "session",
    week: "semaine",
    noLimits: "sans limites",
    rows: [
      { name: "Principal", kind: "login", session: 26, week: 48 },
      { name: "Travail", kind: "login", session: 71, week: 83 },
      { name: "Intégration continue", kind: "token", session: null, week: null },
    ],
    opensWith: "s'ouvre avec",
    once: "un autre, juste cette fois",
    switch: "change le compte actif",
    switchLabel: "Utiliser {name}",
  },
  privacy: {
    title: "Il lit votre utilisation. Rien d'autre.",
    readsTitle: "Ce qu'il lit",
    reads: [
      "La réponse de claude /usage, sans enregistrer cette session dans votre historique.",
      "Le nombre de tokens de vos sessions Claude Code sur ce Mac, jamais le contenu des conversations.",
      "Si vous l'activez, votre session claude.ai dans le navigateur, pour les remises à zéro gratuites et l'usage supplémentaire. macOS demande d'abord.",
    ],
    neverTitle: "Ce qu'il ne fait jamais",
    never: [
      "Envoyer quoi que ce soit à ses propres serveurs. Pas de compte, pas d'analytics, pas de télémétrie.",
      "Toucher à vos connexions Claude Code. Chaque compte est géré par Claude Code lui-même.",
      "Stocker des tokens dans des fichiers. Ceux que vous collez vont dans votre Trousseau.",
    ],
  },
  install: {
    title: "L'installation prend trente secondes.",
    steps: [
      { title: "Téléchargez le .dmg", text: "Version {version}, signée et notarisée." },
      { title: "Glissez Orbix dans Applications", text: "Dans la fenêtre qui s'ouvre." },
      { title: "Ouvrez-le", text: "Il apparaît dans la barre des menus, en haut à droite, et vous demande s'il doit s'ouvrir à la connexion." },
    ],
    download: "Télécharger Orbix {version}",
    note: "Il vous faut Claude Code installé et connecté.",
    allReleases: "Toutes les versions sur GitHub",
    window: "Fenêtre d'installation : Orbix à gauche, le dossier Applications à droite",
    drag: "Glissez Orbix dans le dossier Applications",
    applications: "Applications",
  },
  faq: {
    title: "Questions",
    items: [
      { q: "Combien ça coûte ?", a: "Rien. Orbix est gratuit et son code est sur GitHub." },
      {
        q: "De quoi ai-je besoin ?",
        a: "Un Mac sous macOS 14 ou ultérieur, et Claude Code installé et connecté. Orbix demande vos limites à claude, vous n'avez donc aucune clé à coller.",
      },
      {
        q: "Ça marche avec Pro, Max, Team ou Enterprise ?",
        a: "Avec tout abonnement qui affiche des limites dans claude /usage. Sur les offres sans limite de 5 heures, il suit la limite hebdomadaire. Si votre organisation n'a pas de limites, Orbix affiche quand même l'activité et le coût équivalent.",
      },
      {
        q: "En quelle langue est l'app ?",
        a: "En anglais et en espagnol. Elle suit la langue de votre Mac : en espagnol si votre Mac est en espagnol, en anglais pour toute autre langue.",
      },
      {
        q: "Pourquoi un compte avec token n'affiche pas de limites ?",
        a: "Les tokens longue durée de claude setup-token servent uniquement à utiliser le modèle ; Claude Code n'en communique pas les limites. Orbix le signale sur ce compte et continue d'afficher son activité.",
      },
      {
        q: "S'ouvre-t-il au démarrage du Mac ?",
        a: "Si vous le voulez. La première fois, il demande s'il doit s'ouvrir à la connexion, et vous pouvez changer d'avis dans ses réglages ou dans Réglages Système, Général, Ouverture. Il ne s'ajoute jamais sans demander.",
      },
      {
        q: "Comment se met-il à jour ?",
        a: "Tout seul. Une fois par jour, il cherche une nouvelle version, la télécharge, vérifie sa signature et redémarre. Vous pouvez aussi vérifier depuis ses réglages.",
      },
      {
        q: "Est-ce une app officielle d'Anthropic ?",
        a: "Non. Orbix est un projet indépendant, sans lien avec Anthropic. Claude et Claude Code sont des marques d'Anthropic.",
      },
    ],
  },
  footer: {
    madeBy: "Créé par",
    legal: "Orbix n'est pas affilié à Anthropic. Claude est une marque d'Anthropic.",
    site: "Ce site n'utilise ni cookies ni analytics.",
    source: "Code source",
    languages: "Langues",
  },
};

export default fr;
