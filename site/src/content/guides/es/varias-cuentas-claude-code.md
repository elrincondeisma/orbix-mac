---
key: multiple-accounts
urlSlug: varias-cuentas-claude-code
title: Cómo usar varias cuentas de Claude Code en un Mac
seoTitle: "Varias cuentas de Claude Code en el mismo Mac: cómo cambiar"
description: "Cómo tener la cuenta personal y la del trabajo en Claude Code a la vez con CLAUDE_CONFIG_DIR, cómo usar un token de larga duración y cómo cambiar de una a otra."
order: 3
published: 2026-11-18
updated: 2026-11-18
---

Claude Code guarda el login, los ajustes y el historial en `~/.claude`. Mientras uses una sola cuenta no tienes que pensar en ello, pero si tienes la personal y la del trabajo, o una cuenta para scripts, necesitas que cada una viva en su propia carpeta.

Cada cuenta tiene además sus propios límites de sesión y de semana. Cuando una se acerca al tope, cambiar a otra te deja seguir trabajando.

## Una carpeta por cuenta con CLAUDE_CONFIG_DIR

La variable `CLAUDE_CONFIG_DIR` le dice a Claude Code qué carpeta usar en lugar de `~/.claude`. Según la [documentación de autenticación](https://code.claude.com/docs/en/authentication), cada carpeta tiene sus propios ajustes, su historial de sesiones y su login de claude.ai o su clave de API.

La forma más sencilla es un alias en tu `~/.zshrc`:

```bash
alias claude-trabajo='CLAUDE_CONFIG_DIR=~/.claude-trabajo claude'
```

Abre una terminal nueva, ejecuta `claude-trabajo` y entra con `/login` usando la cuenta del trabajo. Lo haces una vez; a partir de ahí, `claude` sigue entrando con tu cuenta de siempre y `claude-trabajo` con la otra.

En macOS, la credencial se guarda en el Llavero asociada a esa carpeta, así que los dos logins no se pisan.

### Lo que no se comparte

Una carpeta nueva es un Claude Code vacío. Tus ajustes, tu `CLAUDE.md` con instrucciones, tus skills, tus comandos y tus agentes siguen en `~/.claude` y la otra cuenta no los ve. Si quieres los mismos en las dos, enlázalos:

```bash
for f in settings.json CLAUDE.md skills commands agents; do
  ln -s ~/.claude/$f ~/.claude-trabajo/$f
done
```

El login y los servidores MCP conviene dejarlos separados: cada cuenta tiene los suyos.

## Tokens de larga duración

Para una cuenta que no va a abrir el navegador (un servidor, una integración continua o un script) existe:

```bash
claude setup-token
```

Hace el login en el navegador e imprime un token OAuth que dura un año. No lo guarda en ningún sitio: lo copias y lo pasas en la variable `CLAUDE_CODE_OAUTH_TOKEN`. Funciona con planes Pro, Max, Ultra, Team y Enterprise.

Tiene dos limitaciones que conviene conocer:

- el token solo sirve para hacer peticiones al modelo, así que Claude Code no informa de los límites de esa cuenta;
- si en el mismo entorno hay una `ANTHROPIC_API_KEY`, la clave tiene prioridad sobre el token.

No dejes el token escrito en `~/.zshrc` ni en un fichero del repositorio. En el Mac, el sitio para guardarlo es el Llavero.

## Cambiar de cuenta sin aliases, con Orbix

Los aliases funcionan, pero tienes que acordarte de cuál usar en cada terminal, y las apps como VS Code no leen tu `~/.zshrc`.

[Orbix](/es/) gestiona esto como perfiles. Cada perfil es una cuenta con su carpeta en `~/.claude-perfiles/<nombre>`. Si es de tipo login, se abre una Terminal y haces `/login` una vez. Si es un token, pegas el de `claude setup-token` y Orbix lo guarda en tu Llavero.

Al crear un perfil, Orbix enlaza tus ajustes, tu `CLAUDE.md`, tus skills, tus comandos y tus agentes con la cuenta principal. El login, la configuración de `.claude.json` y los servidores MCP quedan separados.

Para cambiar de cuenta enciendes su interruptor en el panel. Los próximos `claude` que abras entran con ella, también en los panes de herdr. Desde la terminal tienes:

```bash
claude                      # abre Claude Code con la cuenta activa
claude --perfil trabajo     # otra cuenta, solo esta vez
orbix-perfil trabajo        # cambia la cuenta activa
orbix-perfil                # muestra la activa y las disponibles
```

La opción «Aplicar también a las apps» hace que VS Code y otras apps que lanzan Claude Code usen el perfil activo. Los tokens nunca se exponen así: solo se aplica la carpeta.

El panel enseña la sesión y la semana de cada cuenta en su fila, así que antes de cambiar ves cuál tiene margen. Para saber qué significa cada porcentaje, lee [los límites de 5 horas y semanal, explicados](/es/guias/limites-de-claude-explicados/).
