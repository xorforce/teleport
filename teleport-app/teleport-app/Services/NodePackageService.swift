//
//  NodePackageService.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import Foundation

class NodePackageService {
    static let shared = NodePackageService()

    private let homeDir = FileManager.default.homeDirectoryForCurrentUser

    // Common installation paths for npm/node
    private var npmPaths: [String] {
        [
            "/opt/homebrew/bin/npm",                    // Homebrew on Apple Silicon
            "/usr/local/bin/npm",                       // Homebrew on Intel / system
            homeDir.appendingPathComponent(".nvm/current/bin/npm").path,  // nvm
            homeDir.appendingPathComponent(".fnm/current/bin/npm").path,  // fnm
            homeDir.appendingPathComponent(".local/share/mise/shims/npm").path,  // mise shim
            homeDir.appendingPathComponent(".asdf/shims/npm").path,       // asdf
            homeDir.appendingPathComponent(".volta/bin/npm").path,        // volta
        ]
    }

    // Common installation paths for bun
    private var bunPaths: [String] {
        [
            homeDir.appendingPathComponent(".bun/bin/bun").path,  // Default bun install
            "/opt/homebrew/bin/bun",                               // Homebrew on Apple Silicon
            "/usr/local/bin/bun",                                  // Homebrew on Intel
        ]
    }

    // Common installation paths for pnpm
    private var pnpmPaths: [String] {
        [
            "/opt/homebrew/bin/pnpm",                   // Homebrew on Apple Silicon
            "/usr/local/bin/pnpm",                      // Homebrew on Intel
            homeDir.appendingPathComponent(".local/share/pnpm/pnpm").path,  // pnpm standalone
            homeDir.appendingPathComponent(".nvm/current/bin/pnpm").path,   // nvm global install
            homeDir.appendingPathComponent(".fnm/current/bin/pnpm").path,   // fnm global install
            homeDir.appendingPathComponent(".local/share/mise/shims/pnpm").path,  // mise shim
            homeDir.appendingPathComponent(".asdf/shims/pnpm").path,        // asdf
            homeDir.appendingPathComponent(".volta/bin/pnpm").path,         // volta
        ]
    }

    // Common installation paths for yarn
    private var yarnPaths: [String] {
        [
            "/opt/homebrew/bin/yarn",                   // Homebrew on Apple Silicon
            "/usr/local/bin/yarn",                      // Homebrew on Intel
            homeDir.appendingPathComponent(".yarn/bin/yarn").path,           // yarn standalone
            homeDir.appendingPathComponent(".nvm/current/bin/yarn").path,    // nvm global install
            homeDir.appendingPathComponent(".fnm/current/bin/yarn").path,    // fnm global install
            homeDir.appendingPathComponent(".local/share/mise/shims/yarn").path,  // mise shim
            homeDir.appendingPathComponent(".asdf/shims/yarn").path,         // asdf
            homeDir.appendingPathComponent(".volta/bin/yarn").path,          // volta
        ]
    }

    private func findExecutable(in paths: [String]) -> String? {
        paths.first { FileManager.default.fileExists(atPath: $0) }
    }

    private init() {}

    func detectNodePackages() async -> NodePackages {
        var packages = NodePackages()

        // Detect npm
        if let npmPackages = detectNPM() {
            packages.npm = npmPackages
        }

        // Detect bun
        if let bunPackages = detectBun() {
            packages.bun = bunPackages
        }

        // Detect pnpm
        if let pnpmPackages = detectPNPM() {
            packages.pnpm = pnpmPackages
        }

        // Detect yarn
        if let yarnPackages = detectYarn() {
            packages.yarn = yarnPackages
        }

        return packages
    }

    private func detectNPM() -> [PackageInfo]? {
        guard let npmPath = findExecutable(in: npmPaths) else { return nil }

        guard let output = shellCommand(npmPath, arguments: ["list", "-g", "--depth=0", "--json"]),
              let data = output.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dependencies = json["dependencies"] as? [String: [String: Any]] else {
            return nil
        }

        return dependencies.compactMap { name, info in
            guard let version = info["version"] as? String else { return nil }
            return PackageInfo(name: name, version: version)
        }
    }

    private func detectBun() -> [PackageInfo]? {
        guard let bunPath = findExecutable(in: bunPaths) else { return nil }

        guard let output = shellCommand(bunPath, arguments: ["pm", "ls", "-g"]) else {
            return nil
        }

        return output.components(separatedBy: .newlines)
            .compactMap { line in
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return nil }

                // bun outputs format like "package@version" or " └── package@version"
                let cleaned = trimmed.replacingOccurrences(of: "└── ", with: "")
                                     .replacingOccurrences(of: "├── ", with: "")
                                     .trimmingCharacters(in: .whitespacesAndNewlines)

                // Handle scoped packages like @scope/package@version
                if let lastAt = cleaned.lastIndex(of: "@"), lastAt != cleaned.startIndex {
                    let name = String(cleaned[..<lastAt])
                    let version = String(cleaned[cleaned.index(after: lastAt)...])
                    return PackageInfo(name: name, version: version)
                }

                return nil
            }
    }

    private func detectPNPM() -> [PackageInfo]? {
        guard let pnpmPath = findExecutable(in: pnpmPaths) else { return nil }

        guard let output = shellCommand(pnpmPath, arguments: ["list", "-g", "--depth=0", "--json"]),
              let data = output.data(using: .utf8) else {
            return nil
        }

        // pnpm JSON output is an array of objects with name/version
        if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return jsonArray.compactMap { item in
                guard let name = item["name"] as? String,
                      let version = item["version"] as? String else { return nil }
                return PackageInfo(name: name, version: version)
            }
        }

        // Sometimes pnpm returns a single object with dependencies
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let dependencies = json["dependencies"] as? [String: [String: Any]] {
            return dependencies.compactMap { name, info in
                guard let version = info["version"] as? String else { return nil }
                return PackageInfo(name: name, version: version)
            }
        }

        return nil
    }

    private func detectYarn() -> [PackageInfo]? {
        guard let yarnPath = findExecutable(in: yarnPaths) else { return nil }

        guard let output = shellCommand(yarnPath, arguments: ["global", "list", "--json"]) else {
            return nil
        }

        // Yarn outputs JSON lines
        return output.components(separatedBy: .newlines)
            .compactMap { line in
                guard let data = line.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let type = json["type"] as? String,
                      type == "tree",
                      let dataDict = json["data"] as? [String: Any],
                      let name = dataDict["name"] as? String,
                      let version = dataDict["version"] as? String else {
                    return nil
                }

                return PackageInfo(name: name, version: version)
            }
    }

    private func shellCommand(_ executablePath: String, arguments: [String] = []) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments

        // Set up environment with proper PATH
        var environment = ProcessInfo.processInfo.environment
        let additionalPaths = [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            homeDir.appendingPathComponent(".bun/bin").path,
            homeDir.appendingPathComponent(".nvm/current/bin").path,
            homeDir.appendingPathComponent(".fnm/current/bin").path,
            homeDir.appendingPathComponent(".local/share/mise/shims").path,
        ]
        let currentPath = environment["PATH"] ?? "/usr/bin:/bin"
        environment["PATH"] = (additionalPaths + [currentPath]).joined(separator: ":")
        process.environment = environment

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()

            // Read data BEFORE waiting for exit to prevent pipe buffer deadlock
            let data = pipe.fileHandleForReading.readDataToEndOfFile()

            process.waitUntilExit()

            if process.terminationStatus == 0 {
                return String(data: data, encoding: .utf8)
            }
        } catch {
            return nil
        }

        return nil
    }
}
