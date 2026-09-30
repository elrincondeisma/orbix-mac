import Foundation

/// The zsh integration: a `claude` function that starts Claude Code with the active profile,
/// plus `orbix-perfil` to list or change it from the terminal. Orbix rewrites the script on
/// every launch so it stays current; ~/.zshrc only sources it.
enum ProfileShell {
    static let sourceLine = "[ -f ~/.config/orbix/shell.zsh ] && source ~/.config/orbix/shell.zsh"

    static let script = #"""
    # Generado por Orbix: perfiles de Claude Code. No lo edites, se reescribe al abrir Orbix.
    #   claude                     usa el perfil activo
    #   claude --perfil <nombre>   usa otro perfil solo esta vez
    #   orbix-perfil [<nombre>]    muestra o cambia el perfil activo

    # `env` runs the real binary (not this function) and can remove variables outright.
    claude() {
      local profile dir token
      if [[ "$1" == "--perfil" ]]; then
        profile="$2"; shift 2
      else
        profile="$(cat ~/.config/orbix/active-profile 2>/dev/null)"
      fi
      if [[ -z "$profile" || "$profile" == "principal" ]]; then
        env -u CLAUDE_CONFIG_DIR -u CLAUDE_CODE_OAUTH_TOKEN claude "$@"
        return
      fi
      dir="$HOME/.claude-perfiles/$profile"
      if [[ ! -d "$dir" ]]; then
        echo "Orbix: no existe el perfil «$profile» (orbix-perfil para ver los que hay)" >&2
        return 1
      fi
      if [[ -f "$dir/.orbix-token" ]]; then
        token="$(/usr/bin/security find-generic-password -a "$profile" -s dev.orbix.profile-token -w 2>/dev/null)" || {
          echo "Orbix: no encuentro el token del perfil «$profile» en el Llavero" >&2
          return 1
        }
        env CLAUDE_CONFIG_DIR="$dir" CLAUDE_CODE_OAUTH_TOKEN="$token" claude "$@"
      else
        env -u CLAUDE_CODE_OAUTH_TOKEN CLAUDE_CONFIG_DIR="$dir" claude "$@"
      fi
    }

    orbix-perfil() {
      local file=~/.config/orbix/active-profile active
      active="$(cat "$file" 2>/dev/null)"; active="${active:-principal}"
      if [[ -z "$1" ]]; then
        echo "Perfil activo: $active"
        echo "Disponibles: principal $(ls ~/.claude-perfiles 2>/dev/null | tr '\n' ' ')"
        return
      fi
      if [[ "$1" != "principal" && ! -d ~/.claude-perfiles/$1 ]]; then
        echo "No existe el perfil «$1»" >&2
        return 1
      fi
      mkdir -p ~/.config/orbix && print -r -- "$1" > "$file" && echo "Perfil activo: $1"
    }
    """#

    static func writeScript() {
        try? FileManager.default.createDirectory(at: ProfilePaths.orbixConfig, withIntermediateDirectories: true)
        try? script.write(to: ProfilePaths.shellScript, atomically: true, encoding: .utf8)
    }

    static var isInstalled: Bool {
        (try? String(contentsOf: ProfilePaths.zshrc, encoding: .utf8))?.contains("orbix/shell.zsh") ?? false
    }

    /// Appends the source line to ~/.zshrc (only when the user presses the button).
    static func install() throws {
        guard !isInstalled else { return }
        let existing = (try? String(contentsOf: ProfilePaths.zshrc, encoding: .utf8)) ?? ""
        let separator = existing.isEmpty || existing.hasSuffix("\n") ? "" : "\n"
        let block = "\(separator)\n# Orbix: perfiles de Claude Code\n\(sourceLine)\n"
        if FileManager.default.fileExists(atPath: ProfilePaths.zshrc.path) {
            let handle = try FileHandle(forWritingTo: ProfilePaths.zshrc)
            defer { try? handle.close() }
            handle.seekToEndOfFile()
            handle.write(Data(block.utf8))
        } else {
            try block.write(to: ProfilePaths.zshrc, atomically: true, encoding: .utf8)
        }
    }
}
