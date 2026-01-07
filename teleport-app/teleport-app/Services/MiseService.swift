//
//  MiseService.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import Foundation

class MiseService {
    static let shared = MiseService()
    
    private init() {}
    
    func detectMise() async -> Mise? {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        
        // Check for mise config file
        let configPath = homeDir.appendingPathComponent(".config/mise/config.toml")
        let configExists = FileManager.default.fileExists(atPath: configPath.path)
        
        // Check for .tool-versions file
        let toolVersionsPath = homeDir.appendingPathComponent(".tool-versions")
        let toolVersionsExists = FileManager.default.fileExists(atPath: toolVersionsPath.path)
        
        guard configExists || toolVersionsExists else {
            return nil
        }
        
        var mise = Mise()
        
        // Read config file if it exists
        if configExists, let configData = try? Data(contentsOf: configPath) {
            mise.configFile = String(data: configData, encoding: .utf8)
        }
        
        // Read .tool-versions if it exists
        if toolVersionsExists, let toolVersionsData = try? Data(contentsOf: toolVersionsPath) {
            let content = String(data: toolVersionsData, encoding: .utf8) ?? ""
            mise.toolVersions = content
            mise.tools = parseToolVersions(content)
        }
        
        return mise
    }
    
    private func parseToolVersions(_ content: String) -> [String: String] {
        var tools: [String: String] = [:]
        
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }
            
            let parts = trimmed.components(separatedBy: .whitespaces)
            if parts.count >= 2 {
                tools[parts[0]] = parts[1]
            }
        }
        
        return tools
    }
}

