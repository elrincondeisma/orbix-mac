import type { Dict } from "./config";

const es: Dict = {
  meta: {
    title: "Orbix: límites de Claude Code en la barra de menús del Mac",
    description:
      "App gratis para la barra de menús del Mac: cuánto te queda de la sesión de 5 horas y de la semana de Claude Code, cuándo se reinician y qué costaría por API.",
    ogAlt: "Orbix: el aro de uso en la barra de menús del Mac y su panel con la sesión de 5 horas y los límites semanales",
  },
  nav: {
    label: "Secciones",
    session: "Cómo funciona",
    panel: "Panel",
    accounts: "Cuentas",
    privacy: "Privacidad",
    install: "Instalar",
    faq: "Preguntas",
    download: "Descargar",
    language: "Idioma",
    openPanel: "Abrir el panel de Orbix",
    home: "Orbix, inicio",
    skip: "Saltar al contenido",
  },
  hero: {
    title: "Mira tu límite de Claude antes de llegar a él.",
    lede: "Orbix es una app gratis para ver el uso de Claude Code desde la barra de menús del Mac. Te dice cuánto te queda de la sesión de 5 horas y de la semana, cuándo se reinicia cada una y qué te costaría ese uso por API.",
    download: "Descargar para Mac",
    source: "Ver en GitHub",
    meta: "Versión {version}, gratis. macOS 14 o posterior, Apple Silicon e Intel. Firmada y notarizada por Apple.",
  },
  ring: {
    label: "Uso de la sesión de cinco horas",
    used: "usado",
    session: "Sesión de 5 h",
    weekly: "Semanal",
    now: "Ahora",
    resets: "Se reinicia",
    reset: "Sesión nueva",
  },
  session: {
    title: "Una sesión, del primer prompt al reinicio",
    steps: [
      {
        title: "Al 70 %, el aro se vuelve ámbar.",
        text: "Te da para terminar lo que estás haciendo. Orbix te dice a qué hora exacta se reinicia la sesión, así que decides si seguir o esperar.",
      },
      {
        title: "Al 90 %, rojo: cambia o para.",
        text: "Pasa a otra cuenta de Claude Code con un clic, o vuelve después del reinicio. Se acabó quedarte a medias en mitad de una tarea.",
      },
      {
        title: "Reinicio. Cinco horas nuevas.",
        text: "El aro se vacía. El límite semanal lleva su propia cuenta, con su día y su hora de reinicio, justo debajo.",
      },
    ],
  },
  tour: {
    title: "Todo lo demás, a un clic.",
    lede: "Un clic en el icono de la barra de menús y se abre el panel. La vista compacta enseña la sesión y los límites; la completa, todo lo demás. Señala una sección para encontrarla en el panel.",
    alt: "El panel completo de Orbix: sesión, límites semanales, cuentas, extras sin usar, coste por API, actividad y modelos",
    note: "",
    regions: [
      { title: "La sesión de 5 horas", text: "Cuánto te queda de la ventana actual y a qué hora se reinicia. El aro pasa a ámbar cerca del límite." },
      { title: "Los límites semanales", text: "El general y los de cada modelo, con su día y su hora de reinicio." },
      { title: "Tus cuentas", text: "Cada perfil de Claude Code con su sesión y su semana. Enciende uno y el próximo claude lo usa." },
      { title: "Lo que no has gastado", text: "Reinicios gratis guardados, saldo prepago y uso extra del mes, leídos de claude.ai." },
      { title: "Lo que costaría por API", text: "La sesión actual y los últimos 30 días a precio de lista, calculados con tus sesiones locales." },
      { title: "Actividad", text: "Tokens por día, respuestas y sesiones de Claude Code en la última semana." },
      { title: "Los modelos que usas", text: "En qué modelos te apoyas, con sus tokens y su coste por API." },
    ],
  },
  accounts: {
    title: "Varias cuentas, un interruptor.",
    body: [
      "Cada cuenta de Claude Code vive en su propio perfil, con su login, su historial y sus servidores MCP. Los ajustes, tus instrucciones y tus skills se comparten.",
      "Enciende una en Orbix y el próximo claude que abras entra con ella, en la Terminal, en VS Code o en los panes de herdr. También funciona con tokens de larga duración, que se guardan en tu Llavero.",
    ],
    try: "Prueba los interruptores",
    cardTitle: "Cuentas",
    session: "sesión",
    week: "semana",
    noLimits: "sin límites",
    rows: [
      { name: "Principal", kind: "login", session: 26, week: 48 },
      { name: "Trabajo", kind: "login", session: 71, week: 83 },
      { name: "Integración continua", kind: "token", session: null, week: null },
    ],
    opensWith: "entra con",
    once: "otra, solo esta vez",
    switch: "cambia la activa",
    switchLabel: "Usar {name}",
  },
  privacy: {
    title: "Mira tu uso. Nada más.",
    readsTitle: "Qué lee",
    reads: [
      "Tus límites, con el token que Claude Code guarda en tu Llavero o, si no puede, con la respuesta de claude /usage, sin guardar esa sesión en tu historial.",
      "El recuento de tokens de tus sesiones de Claude Code en este Mac, nunca lo que dicen las conversaciones.",
      "Si lo activas, tu sesión de claude.ai en el navegador, para los reinicios gratis y el uso extra. macOS te pide permiso antes.",
    ],
    neverTitle: "Qué no hace nunca",
    never: [
      "Enviar nada a servidores propios. No tiene cuentas, analíticas ni telemetría.",
      "Tocar tus logins de Claude Code. Cada cuenta la gestiona el propio Claude Code.",
      "Guardar tokens en ficheros. Los que pegas van a tu Llavero.",
    ],
  },
  install: {
    title: "Instalar lleva medio minuto.",
    steps: [
      { title: "Descarga el .dmg", text: "Versión {version}, firmada y notarizada." },
      { title: "Arrastra Orbix a Aplicaciones", text: "En la ventana que se abre." },
      { title: "Ábrela", text: "Aparece en la barra de menús, arriba a la derecha, y te pregunta si quieres que se abra al iniciar sesión." },
    ],
    download: "Descargar Orbix {version}",
    note: "Necesitas Claude Code instalado y con la sesión iniciada.",
    allReleases: "Todas las versiones en GitHub",
    window: "Ventana del instalador: Orbix a la izquierda y la carpeta Aplicaciones a la derecha",
    drag: "Arrastra Orbix a la carpeta Aplicaciones",
    applications: "Aplicaciones",
  },
  faq: {
    title: "Preguntas",
    items: [
      { q: "¿Cuánto cuesta?", a: "Nada. Orbix es gratis y su código está en GitHub." },
      {
        q: "¿Qué necesito?",
        a: "Un Mac con macOS 14 o posterior y Claude Code instalado y con la sesión iniciada. Orbix le pregunta a claude por tus límites, así que no tienes que pegar ninguna clave.",
      },
      {
        q: "¿Funciona con Pro, Max, Team o Enterprise?",
        a: "Con cualquier plan de suscripción que muestre límites en claude /usage. En los planes sin límite de 5 horas sigue el semanal. Si en tu organización no hay límites, Orbix sigue mostrando la actividad y el coste equivalente.",
      },
      {
        q: "¿En qué idioma está la app?",
        a: "En español y en inglés. Sigue el idioma de tu Mac: en español si tu Mac está en español y en inglés en cualquier otro idioma.",
      },
      {
        q: "¿Por qué una cuenta con token no enseña límites?",
        a: "Los tokens de larga duración de claude setup-token solo sirven para usar el modelo; Claude Code no informa de sus límites. Orbix lo indica en esa cuenta y sigue mostrando su actividad.",
      },
      {
        q: "¿Se abre sola al encender el Mac?",
        a: "Si quieres. La primera vez te pregunta si abrirla al iniciar sesión, y lo cambias cuando quieras en sus ajustes o en Ajustes del Sistema, General, Ítems de inicio. Nunca se añade sin preguntarte.",
      },
      {
        q: "¿Cómo se actualiza?",
        a: "Sola. Una vez al día comprueba si hay versión nueva, la descarga, verifica su firma y se reinicia. También puedes buscarla desde sus ajustes.",
      },
      {
        q: "¿Es una app oficial de Anthropic?",
        a: "No. Orbix es un proyecto independiente y no está afiliado a Anthropic. Claude y Claude Code son marcas de Anthropic.",
      },
    ],
  },
  footer: {
    madeBy: "Hecho por",
    legal: "Orbix no está afiliado a Anthropic. Claude es una marca de Anthropic.",
    site: "Esta web no usa cookies ni analíticas.",
    source: "Código fuente",
    languages: "Idiomas",
  },
};

export default es;
