//
//  MiseService.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import Foundation

class MiseService {
    static let shared = MiseService()

    private let homeDir = FileManager.default.homeDirectoryForCurrentUser

    // Common mise data directory paths
    private var miseDataPaths: [URL] {
        [
            homeDir.appendingPathComponent(".local/share/mise"),      // Default XDG location
            homeDir.appendingPathComponent(".mise"),                   // Legacy location
        ]
    }

    private var miseConfigPaths: [URL] {
        [
            homeDir.appendingPathComponent(".config/mise/config.toml"),
            homeDir.appendingPathComponent(".config/mise/settings.toml"),
            homeDir.appendingPathComponent(".mise.toml"),
        ]
    }

    private init() {}

    func detectMise() async -> Mise? {
        // Check for mise config file
        var configContent: String? = nil
        for configPath in miseConfigPaths {
            if FileManager.default.fileExists(atPath: configPath.path),
               let data = try? Data(contentsOf: configPath) {
                configContent = String(data: data, encoding: .utf8)
                break
            }
        }

        // Check for .tool-versions file
        let toolVersionsPath = homeDir.appendingPathComponent(".tool-versions")
        let toolVersionsExists = FileManager.default.fileExists(atPath: toolVersionsPath.path)

        // Check for mise data directory with installed tools
        let installedTools = detectInstalledTools()

        // If no mise presence detected, return nil
        guard configContent != nil || toolVersionsExists || !installedTools.isEmpty else {
            return nil
        }

        var mise = Mise()

        // Read config file if it exists
        mise.configFile = configContent

        // Read .tool-versions if it exists
        if toolVersionsExists, let toolVersionsData = try? Data(contentsOf: toolVersionsPath) {
            let content = String(data: toolVersionsData, encoding: .utf8) ?? ""
            mise.toolVersions = content
            mise.tools = parseToolVersions(content)
        }

        // Merge installed tools (prefer .tool-versions if both exist)
        if mise.tools == nil || mise.tools?.isEmpty == true {
            mise.tools = installedTools
        } else {
            // Add any installed tools not in .tool-versions
            for (tool, version) in installedTools {
                if mise.tools?[tool] == nil {
                    mise.tools?[tool] = version
                }
            }
        }

        return mise
    }

    /// Detect installed tools by reading mise's data directory structure
    private func detectInstalledTools() -> [String: String] {
        var tools: [String: String] = [:]

        for dataPath in miseDataPaths {
            let installsPath = dataPath.appendingPathComponent("installs")

            guard FileManager.default.fileExists(atPath: installsPath.path) else {
                continue
            }

            // Each subdirectory in installs is a tool name
            guard let toolDirs = try? FileManager.default.contentsOfDirectory(
                at: installsPath,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else {
                continue
            }

            for toolDir in toolDirs {
                var isDirectory: ObjCBool = false
                guard FileManager.default.fileExists(atPath: toolDir.path, isDirectory: &isDirectory),
                      isDirectory.boolValue else {
                    continue
                }

                let toolName = toolDir.lastPathComponent

                // Each subdirectory in the tool directory is a version
                guard let versionDirs = try? FileManager.default.contentsOfDirectory(
                    at: toolDir,
                    includingPropertiesForKeys: [.isDirectoryKey],
                    options: [.skipsHiddenFiles]
                ) else {
                    continue
                }

                // Get the latest version (by directory modification date or alphabetically)
                let versions = versionDirs
                    .filter { url in
                        var isDir: ObjCBool = false
                        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
                    }
                    .map { $0.lastPathComponent }
                    .sorted()

                if let latestVersion = versions.last {
                    tools[toolName] = latestVersion
                }
            }
        }

        return tools
    }

    private func parseToolVersions(_ content: String) -> [String: String] {
        var tools: [String: String] = [:]

        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }

            let parts = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            if parts.count >= 2 {
                tools[parts[0]] = parts[1]
            }
        }

        return tools
    }
}
