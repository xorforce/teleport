//
//  HomebrewService.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import Foundation

class HomebrewService {
    static let shared = HomebrewService()
    
    private init() {}
    
    func detectHomebrew() async -> Homebrew? {
        // Check if brew command exists
        guard shellCommandExists("brew") else {
            return nil
        }
        
        // Get Homebrew prefix
        let prefix = shellCommand("brew", arguments: ["--prefix"])?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Generate Brewfile
        let brewfile = shellCommand("brew", arguments: ["bundle", "dump", "--force"])
        
        // List installed packages
        let packagesOutput = shellCommand("brew", arguments: ["list", "--formula"])
        let packages = packagesOutput?.components(separatedBy: .newlines).filter { !$0.isEmpty } ?? []
        
        return Homebrew(
            brewfile: brewfile ?? "",
            packages: packages.isEmpty ? nil : packages
        )
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

