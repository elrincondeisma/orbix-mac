import Foundation

/// herdr (herdr.dev), a terminal workspace manager for coding agents. Its panes run the user's
/// zsh, so the `claude` function of `ProfileShell` picks the profile there too. Orbix runs
/// outside herdr and reaches the default session through its CLI.
enum Herdr {
    private static var binary: URL? {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return ["\(home)/.local/bin/herdr", "/opt/homebrew/bin/herdr", "/usr/local/bin/herdr"]
            .first { FileManager.default.isExecutableFile(atPath: $0) }
            .map { URL(fileURLWithPath: $0) }
    }

    /// The output of a herdr command, or nil when herdr is missing or the command failed.
    private static func run(_ arguments: [String]) -> String? {
        guard let binary,
              let (status, output) = try? Shell.run(binary, arguments: arguments, timeout: 5), status == 0
        else { return nil }
        return output
    }

    /// The `result` of a herdr command that answers with JSON.
    private static func result(_ arguments: [String]) -> [String: Any]? {
        guard let output = run(arguments),
              let json = try? JSONSerialization.jsonObject(with: Data(output.utf8)) as? [String: Any]
        else { return nil }
        return json["result"] as? [String: Any]
    }

    /// Opens a tab in the focused workspace running `claude` as this profile.
    /// Returns false when there is no herdr session to open it in.
    static func openClaude(profileSlug: String, label: String, focus: Bool = true) -> Bool {
        guard let workspaces = result(["workspace", "list"])?["workspaces"] as? [[String: Any]],
              let workspace = workspaces.first(where: { $0["focused"] as? Bool == true })?["workspace_id"] as? String,
              let created = result(["tab", "create", "--workspace", workspace, "--label", label,
                                    focus ? "--focus" : "--no-focus"]),
              let pane = (created["root_pane"] as? [String: Any])?["pane_id"] as? String
        else { return false }
        // Answers with no JSON: a zero exit status is its only acknowledgement.
        return run(["pane", "run", pane, "claude --perfil \(profileSlug)"]) != nil
    }

    /// Claude Code agents open in herdr right now. They keep their account until restarted.
    static func claudeAgentCount() -> Int {
        let agents = result(["agent", "list"])?["agents"] as? [[String: Any]] ?? []
        return agents.filter { $0["agent"] as? String == "claude" }.count
    }
}
