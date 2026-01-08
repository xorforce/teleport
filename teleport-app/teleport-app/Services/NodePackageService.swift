//
//  NodePackageService.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import Foundation

class NodePackageService {
    static let shared = NodePackageService()

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
        guard shellCommandExists("npm") else { return nil }

        guard let output = shellCommand("npm", arguments: ["list", "-g", "--depth=0", "--json"]),
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
        guard shellCommandExists("bun") else { return nil }

        guard let output = shellCommand("bun", arguments: ["pm", "ls", "-g"]) else {
            return nil
        }

        return output.components(separatedBy: .newlines)
            .compactMap { line in
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return nil }

                let parts = trimmed.components(separatedBy: "@")
                guard parts.count == 2 else { return nil }

                return PackageInfo(name: parts[0], version: parts[1])
            }
    }

    private func detectPNPM() -> [PackageInfo]? {
        guard shellCommandExists("pnpm") else { return nil }

        guard let output = shellCommand("pnpm", arguments: ["list", "-g", "--depth=0", "--json"]),
              let data = output.data(using: .utf8),
              let packages = try? JSONDecoder().decode([PackageInfo].self, from: data) else {
            return nil
        }

        return packages
    }

    private func detectYarn() -> [PackageInfo]? {
        guard shellCommandExists("yarn") else { return nil }

        guard let output = shellCommand("yarn", arguments: ["global", "list", "--json"]) else {
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

    private func shellCommandExists(_ command: String) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [command]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    private func shellCommand(_ command: String, arguments: [String] = []) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [command] + arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                return String(data: data, encoding: .utf8)
            }
        } catch {
            return nil
        }

        return nil
    }
}
