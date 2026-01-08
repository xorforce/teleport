//
//  HomebrewService.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import Foundation

class HomebrewService {
    static let shared = HomebrewService()

    // Common Homebrew installation paths
    private let brewPaths = [
        "/opt/homebrew/bin/brew",    // Apple Silicon Macs
        "/usr/local/bin/brew",        // Intel Macs
        "/home/linuxbrew/.linuxbrew/bin/brew",  // Linux
    ]

    private var brewPath: String? {
        brewPaths.first { FileManager.default.fileExists(atPath: $0) }
    }

    private init() {}

    func detectHomebrew() async -> Homebrew? {
        // Check if brew command exists at known paths
        guard let brewExecutable = brewPath else {
            return nil
        }

        // Generate Brewfile (use --file=- to output to stdout)
        let brewfile = shellCommand(brewExecutable, arguments: ["bundle", "dump", "--file=-", "--force"])

        // List installed formulae
        let formulaeOutput = shellCommand(brewExecutable, arguments: ["list", "--formula"])
        let formulae = formulaeOutput?
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .sorted() ?? []

        // List installed casks
        let casksOutput = shellCommand(brewExecutable, arguments: ["list", "--cask"])
        let casks = casksOutput?
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .sorted() ?? []

        return Homebrew(
            brewfile: brewfile ?? "",
            packages: formulae.isEmpty ? nil : formulae,
            casks: casks.isEmpty ? nil : casks
        )
    }

    private func shellCommand(_ executablePath: String, arguments: [String] = []) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments

        // Set up environment with proper PATH for Homebrew and disable auto-update
        var environment = ProcessInfo.processInfo.environment
        let homebrewPaths = ["/opt/homebrew/bin", "/usr/local/bin", "/opt/homebrew/sbin", "/usr/local/sbin"]
        let currentPath = environment["PATH"] ?? "/usr/bin:/bin"
        environment["PATH"] = (homebrewPaths + [currentPath]).joined(separator: ":")
        environment["HOMEBREW_NO_AUTO_UPDATE"] = "1"
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
