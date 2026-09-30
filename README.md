# Orbix

App de barra de menús para macOS (SwiftUI) que muestra el uso de **tu cuenta de Claude**:
la ventana de sesión de 5 horas, el límite semanal, los límites semanales por modelo y el uso extra
del mes. Es una versión mínima de [CodexBar](https://github.com/steipete/CodexBar) centrada solo en Claude.

## Instalar

Descarga **`Orbix-<versión>.dmg`** del [último release](https://github.com/elrincondeisma/orbix-mac/releases/latest),
ábrelo y arrastra **Orbix** a **Aplicaciones**. Está firmada con Developer ID y notarizada por Apple, así que se abre
sin avisos. Después se actualiza sola.

## Diseño

La estética (paleta verde esmeralda / casi negro, tarjetas con borde fino, SF Mono para cifras, pastilla de
estado y medidor circular) está adaptada de [ModelNap](https://github.com/eriktaveras/modelnap), MIT License,
Copyright (c) 2026 Taveras Solutions LLC. El nombre y el logo de ModelNap no se reutilizan: Orbix tiene su
propia marca (una órbita con un planeta; en la barra de menús, el arco muestra el uso de la sesión).

## Compilar y ejecutar

Basta con las Command Line Tools (no hace falta Xcode):

```bash
./Scripts/setup-sparkle.sh   # la primera vez
./Scripts/build-app.sh
open build/Orbix.app
```

Para desarrollar: `swift run`.

## Actualizaciones automáticas

Orbix se actualiza sola con [Sparkle](https://sparkle-project.org): una vez al día lee
`https://github.com/elrincondeisma/orbix-mac/releases/latest/download/appcast.xml`, y si hay una versión nueva la
descarga, comprueba su firma EdDSA, se sustituye y se reinicia. Se controla en Ajustes → Actualizaciones.

Publicar una versión:

```bash
./Scripts/setup-sparkle.sh                 # solo la primera vez en un Mac: herramientas de Sparkle
./Scripts/release.sh 0.2.0 "Qué cambia"    # compila, firma, notariza, crea el appcast y el release
```

- La clave privada EdDSA está en el Llavero (cuenta `orbix`); la pública va en `SUPublicEDKey`
  (`Scripts/build-app.sh`). **No generes otra**: las copias instaladas solo aceptan actualizaciones firmadas
  con esta.
- Para que la app abra en otros Macs sin avisos de Gatekeeper hace falta un certificado **Developer ID
  Application** y un perfil de `notarytool`
  (`xcrun notarytool store-credentials orbix-notary --apple-id … --team-id …`). Con él, `release.sh` notariza
  y grapa el ticket automáticamente; sin él se niega a publicar salvo con `ORBIX_ALLOW_UNNOTARIZED=1`.

## De dónde saca los datos

| Orden | Credencial | Endpoint |
|---|---|---|
| 1 | Token OAuth de Claude Code (`~/.claude/.credentials.json` o Llavero `Claude Code-credentials`) | `GET api.anthropic.com/api/oauth/usage` y `/profile` (cabecera `anthropic-beta: oauth-2025-04-20`) |
| 2 | Ninguna: ejecuta `claude -p "/usage" --no-session-persistence` y lee el texto (lo mismo que hace CodexBar) | El propio Claude Code |
| 3 | Credencial manual en Ajustes: cookie `sessionKey` de claude.ai | `GET claude.ai/api/organizations` → `/organizations/{id}/usage` |
| 3 | Credencial manual en Ajustes: token `sk-ant-oat…` | Igual que el 1 |

Además, **Actividad local** lee las sesiones de Claude Code en `~/.claude/projects/**/*.jsonl`
(no necesita credenciales): tokens de hoy y de los últimos 7 días, respuestas, sesiones y modelos más usados.
De cada línea solo se decodifican `timestamp`, `sessionId`, `requestId`, `message.id`, `message.model` y
`message.usage`; la conversación se ignora. Las respuestas se deduplican por `message.id + requestId`, porque
Claude Code escribe una línea por bloque de contenido con el mismo `usage`.

**Si lo pagaras por API**: con los mismos registros estima lo que costaría ese uso con los precios de lista
de la API (`Services/APIPricing.swift`): entrada, salida, lectura de caché y escritura de caché (×1,25 con TTL
de 5 min, ×2 con TTL de 1 h), y el doble en modo rápido. Muestra la sesión actual (la ventana de 5 h que informa
`/usage`) y los últimos 30 días. Solo cuenta este Mac: no incluye claude.ai ni otros equipos.

**Extra sin usar** (como CodexBar): con la sesión de claude.ai leída de Chrome (`Services/ChromeSession.swift`,
cookie `sessionKey` descifrada con la clave «Chrome Safe Storage» del Llavero; macOS pide permiso una vez) o con
una `sessionKey` pegada en Ajustes, consulta `usage?cedar_ember=1` (reinicios gratis guardados y su caducidad),
`prepaid/credits` (saldo prepago) y `overage_spend_limit` (uso extra del mes). Se desactiva en Ajustes.

**Perfiles (varias cuentas)**: cada perfil es una carpeta de Claude Code propia (`~/.claude-perfiles/<nombre>`,
vía `CLAUDE_CONFIG_DIR`) con su login, historial y servidores MCP; ajustes, `CLAUDE.md`, skills, comandos y agentes
se enlazan a `~/.claude` (y el historial, si se elige). Tipos: *login* (haces `/login` una vez dentro) y *token de
larga duración* (`claude setup-token`, guardado en el Llavero y pasado como `CLAUDE_CODE_OAUTH_TOKEN`). El perfil
activo se guarda en `~/.config/orbix/active-profile`; con la integración de terminal (una línea en `~/.zshrc` que
carga `~/.config/orbix/shell.zsh`):

```bash
claude                     # abre Claude Code con el perfil activo
claude --perfil trabajo    # otro perfil solo esta vez
orbix-perfil trabajo       # cambia el perfil activo (Orbix lo refleja)
```

En el panel, un clic en una cuenta la activa y ▸ abre `claude` en una Terminal con ella. Orbix no toca ningún token
de Claude Code: cada login lo gestiona el propio Claude Code en su perfil.

Las dos APIs devuelven el mismo JSON (`five_hour`, `seven_day`, `seven_day_opus`, `seven_day_sonnet`,
`limits[]`, `extra_usage`), así que se decodifica con un solo modelo (`Models/Usage.swift`).

Orbix **nunca renueva** el token de Claude Code: renovarlo rota el refresh token y cerraría la sesión de
`claude`. Si caduca, basta con abrir `claude` en la terminal.

## Estructura

```
Sources/Orbix/
  OrbixApp.swift                 MenuBarExtra + ventana de Ajustes
  UsageStore.swift               Estado, temporizador y elección de credencial
  Models/Usage.swift             JSON de la API → UsageSnapshot
  Services/ClaudeCodeCredentials Lee el token de Claude Code (solo lectura)
  Services/ClaudeCLIUsage.swift  Ejecuta `claude /usage` y lo interpreta
  Services/ClaudeAPI.swift       Clientes OAuth y web
  Services/LocalSessionScanner  Tokens por día y modelo desde las sesiones locales
  Services/APIPricing.swift      Precios de lista de la API por modelo
  Services/ChromeSession.swift   Lee la cookie sessionKey de claude.ai en Chrome
  Services/AppUpdater.swift      Actualizaciones con Sparkle
  Services/Profiles/             Perfiles de Claude Code, tokens y la función de terminal
  Services/SecretStore.swift     Guarda la credencial manual en el Llavero
  Views/Theme.swift              Tokens de color y tipografía (claro/oscuro)
  Views/Components.swift         Tarjeta, pastilla, medidor, chip, aviso
  Views/OrbixMark.swift          Logo e icono de la barra de menús
  Views/                         Panel, tarjetas y ajustes dentro del panel
Scripts/
  build-app.sh                   Empaqueta y firma Orbix.app (universal, con Sparkle)
  release.sh                     Publica una versión en GitHub Releases con su appcast
  setup-sparkle.sh               Descarga las herramientas de Sparkle
  make-dmg.sh                    Instalador .dmg (fondo de Tools/dmgbackground, dmgbuild), firmado y notarizado
  make-icon.sh                   Genera Resources/AppIcon.icns desde Resources/icon/AppIcon.png
  generate-icon.sh               Propuestas de icono con GPT Image 2.5 (OPENAI_API_KEY)
```
