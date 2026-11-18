import type { Dict } from "./config";

// Brazilian Portuguese.
const pt: Dict = {
  meta: {
    title: "Orbix: seu limite do Claude na barra de menus do Mac",
    description:
      "O Orbix mostra quanto resta da sessão de 5 horas e do limite semanal do Claude, quando cada um reinicia e quanto esse uso custaria pela API. Grátis, para macOS.",
    ogAlt: "Orbix: o anel de uso na barra de menus do Mac e seu painel com a sessão de 5 horas e os limites semanais",
  },
  nav: {
    label: "Seções",
    session: "Como funciona",
    panel: "Painel",
    accounts: "Contas",
    privacy: "Privacidade",
    install: "Instalar",
    faq: "Perguntas",
    download: "Baixar",
    language: "Idioma",
    openPanel: "Abrir o painel do Orbix",
    home: "Orbix, início",
    skip: "Pular para o conteúdo",
  },
  hero: {
    title: "Veja seu limite do Claude antes de chegar nele.",
    lede: "O Orbix fica na barra de menus do Mac. Ele mostra quanto resta da sessão de 5 horas e da semana, quando cada uma reinicia e quanto esse uso custaria pela API.",
    download: "Baixar para Mac",
    source: "Ver no GitHub",
    meta: "Versão {version}, grátis. macOS 14 ou posterior, Apple Silicon e Intel. Assinado e notarizado pela Apple.",
  },
  ring: {
    label: "Uso da sessão de cinco horas",
    used: "usado",
    session: "Sessão de 5 h",
    weekly: "Semanal",
    now: "Agora",
    resets: "Reinicia",
    reset: "Nova sessão",
  },
  session: {
    title: "Uma sessão, do primeiro prompt ao reinício",
    steps: [
      {
        title: "Em 70 %, o anel fica âmbar.",
        text: "Ainda dá para terminar o que você está fazendo. O Orbix mostra a hora exata em que a sessão reinicia, para você decidir se continua ou espera.",
      },
      {
        title: "Em 90 %, vermelho: troque ou pare.",
        text: "Mude para outra conta do Claude Code com um clique, ou volte depois do reinício. Chega de bater no limite no meio de uma tarefa.",
      },
      {
        title: "Reinício. Cinco horas novas.",
        text: "O anel se esvazia. O limite semanal segue com a própria contagem, com dia e hora de reinício, logo abaixo.",
      },
    ],
  },
  tour: {
    title: "Todo o resto, a um clique.",
    lede: "Um clique no ícone da barra de menus e o painel abre. A vista compacta mostra a sessão e os limites; a completa, todo o resto. Aponte para uma seção para encontrá-la no painel.",
    alt: "O painel completo do Orbix: sessão, limites semanais, contas, extras não usados, custo na API, atividade e modelos",
    note: "Por enquanto, a interface do app está em espanhol.",
    regions: [
      { title: "A sessão de 5 horas", text: "Quanto resta da janela atual e quando ela reinicia. O anel fica âmbar perto do limite." },
      { title: "Limites semanais", text: "O geral e os de cada modelo, com dia e hora de reinício." },
      { title: "Suas contas", text: "Cada perfil do Claude Code com sua sessão e sua semana. Ative um e o próximo claude usa ele." },
      { title: "Extras não usados", text: "Reinícios grátis guardados, saldo pré-pago e uso extra do mês, lidos do claude.ai." },
      { title: "Quanto custaria na API", text: "A sessão atual e os últimos 30 dias a preço de tabela, calculados a partir das suas sessões locais." },
      { title: "Atividade", text: "Tokens por dia, respostas e sessões no Claude Code na última semana." },
      { title: "Seus modelos", text: "Em quais modelos você mais se apoia, com tokens e custo na API." },
    ],
  },
  accounts: {
    title: "Várias contas, um interruptor.",
    body: [
      "Cada conta do Claude Code vive no próprio perfil, com login, histórico e servidores MCP próprios. Suas configurações, instruções e skills são compartilhadas.",
      "Ative uma no Orbix e o próximo claude que você abrir entra com ela, no Terminal, no VS Code ou nos panes do herdr. Tokens de longa duração também funcionam e ficam nas suas Chaves.",
    ],
    try: "Experimente os interruptores",
    cardTitle: "Contas",
    session: "sessão",
    week: "semana",
    noLimits: "sem limites",
    rows: [
      { name: "Pessoal", kind: "login", session: 26, week: 48 },
      { name: "Trabalho", kind: "login", session: 71, week: 83 },
      { name: "Integração contínua", kind: "token", session: null, week: null },
    ],
    opensWith: "abre com",
    once: "outra, só desta vez",
    switch: "troca a ativa",
    switchLabel: "Usar {name}",
  },
  privacy: {
    title: "Ele lê seu uso. Nada mais.",
    readsTitle: "O que ele lê",
    reads: [
      "A resposta de claude /usage, sem salvar essa sessão no seu histórico.",
      "A contagem de tokens das suas sessões do Claude Code neste Mac, nunca o conteúdo das conversas.",
      "Se você ativar, sua sessão do claude.ai no navegador, para os reinícios grátis e o uso extra. O macOS pede permissão antes.",
    ],
    neverTitle: "O que ele nunca faz",
    never: [
      "Enviar nada para servidores próprios. Não há contas, analytics nem telemetria.",
      "Mexer nos seus logins do Claude Code. Cada conta é gerenciada pelo próprio Claude Code.",
      "Guardar tokens em arquivos. Os que você cola vão para as suas Chaves.",
    ],
  },
  install: {
    title: "A instalação leva meio minuto.",
    steps: [
      { title: "Baixe o .dmg", text: "Versão {version}, assinada e notarizada." },
      { title: "Arraste o Orbix para Aplicativos", text: "Na janela que se abre." },
      { title: "Abra o app", text: "Ele aparece na barra de menus, no canto superior direito, e pergunta se deve abrir ao iniciar a sessão." },
    ],
    download: "Baixar Orbix {version}",
    note: "Você precisa do Claude Code instalado e com a sessão iniciada.",
    allReleases: "Todas as versões no GitHub",
    window: "Janela do instalador: o Orbix à esquerda e a pasta Aplicativos à direita",
    drag: "Arraste o Orbix para a pasta Aplicativos",
    applications: "Aplicativos",
  },
  faq: {
    title: "Perguntas",
    items: [
      { q: "Quanto custa?", a: "Nada. O Orbix é grátis e o código está no GitHub." },
      {
        q: "Do que eu preciso?",
        a: "Um Mac com macOS 14 ou posterior e o Claude Code instalado e com a sessão iniciada. O Orbix pergunta ao claude pelos seus limites, então você não cola nenhuma chave.",
      },
      {
        q: "Funciona com Pro, Max, Team ou Enterprise?",
        a: "Com qualquer plano de assinatura que mostre limites em claude /usage. Nos planos sem limite de 5 horas, ele acompanha o semanal. Se a sua organização não tiver limites, o Orbix continua mostrando a atividade e o custo equivalente.",
      },
      {
        q: "Em que idioma está o app?",
        a: "Em espanhol, por enquanto. Os anéis, as cores e os números se leem igual em qualquer idioma.",
      },
      {
        q: "Por que uma conta com token não mostra limites?",
        a: "Os tokens de longa duração do claude setup-token servem só para usar o modelo; o Claude Code não informa os limites deles. O Orbix avisa isso nessa conta e continua mostrando a atividade.",
      },
      {
        q: "Ele abre sozinho quando ligo o Mac?",
        a: "Se você quiser. Na primeira vez ele pergunta se deve abrir ao iniciar a sessão, e você muda isso quando quiser nos ajustes dele ou em Ajustes do Sistema, Geral, Itens de Início. Ele nunca se adiciona sem perguntar.",
      },
      {
        q: "Como ele se atualiza?",
        a: "Sozinho. Uma vez por dia ele procura uma versão nova, baixa, verifica a assinatura e reinicia. Você também pode procurar pelos ajustes dele.",
      },
      {
        q: "É um app oficial da Anthropic?",
        a: "Não. O Orbix é um projeto independente e não tem vínculo com a Anthropic. Claude e Claude Code são marcas da Anthropic.",
      },
    ],
  },
  footer: {
    madeBy: "Feito por",
    legal: "O Orbix não tem vínculo com a Anthropic. Claude é uma marca da Anthropic.",
    site: "Este site não usa cookies nem analytics.",
    source: "Código-fonte",
    languages: "Idiomas",
  },
};

export default pt;
