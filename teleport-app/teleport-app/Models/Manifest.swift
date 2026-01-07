//
//  Manifest.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import Foundation

// MARK: - Manifest
struct Manifest: Codable {
    let version: String
    let createdAt: Date
    let macOS: MacOSInfo
    var homebrew: Homebrew?
    var nodePackages: NodePackages?
    var mise: Mise?
    var dotfiles: [String]?
    var macSettings: MacSettings?
    var ide: IDE?
    var fonts: [String]?
    var shellHistory: ShellHistory?

    enum CodingKeys: String, CodingKey {
        case version
        case createdAt = "created_at"
        case macOS = "macos"
        case homebrew
        case nodePackages = "node_packages"
        case mise
        case dotfiles
        case macSettings = "mac_settings"
        case ide
        case fonts
        case shellHistory = "shell_history"
    }

    init() {
        self.version = "1.0"
        self.createdAt = Date()
        self.macOS = MacOSInfo()
    }
}

// MARK: - MacOSInfo
struct MacOSInfo: Codable {
    let version: String
    let arch: String

    init() {
        self.version = ProcessInfo.processInfo.operatingSystemVersionString
        #if arch(arm64)
        self.arch = "arm64"
        #else
        self.arch = "x86_64"
        #endif
    }
}

// MARK: - Homebrew
struct Homebrew: Codable {
    let brewfile: String
    var packages: [String]?
}

// MARK: - NodePackages
struct NodePackages: Codable {
    var npm: [PackageInfo]?
    var bun: [PackageInfo]?
    var pnpm: [PackageInfo]?
    var yarn: [PackageInfo]?
}

// MARK: - PackageInfo
struct PackageInfo: Codable, Identifiable {
    let id = UUID()
    let name: String
    let version: String

    enum CodingKeys: String, CodingKey {
        case name, version
    }
}

// MARK: - Mise
struct Mise: Codable {
    var configFile: String?
    var toolVersions: String?
    var tools: [String: String]?

    enum CodingKeys: String, CodingKey {
        case configFile = "config_file"
        case toolVersions = "tool_versions"
        case tools
    }
}

// MARK: - MacSettings
struct MacSettings: Codable {
    var defaults: [String: AnyCodable]?
}

// MARK: - AnyCodable (Helper for Dictionary with Any values)
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            let codableArray = array.map { AnyCodable($0) }
            try container.encode(codableArray)
        case let dictionary as [String: Any]:
            let codableDictionary = dictionary.mapValues { AnyCodable($0) }
            try container.encode(codableDictionary)
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded"))
        }
    }
}

// MARK: - IDE
struct IDE: Codable {
    var vscode: VSCodeConfig?
    var cursor: CursorConfig?
    var xcode: XcodeConfig?
}

// MARK: - VSCodeConfig
struct VSCodeConfig: Codable {
    var settings: String?
    var keybindings: String?
    var extensions: [String]?
}

// MARK: - CursorConfig
struct CursorConfig: Codable {
    var settings: String?
    var keybindings: String?
    var extensions: [String]?
}

// MARK: - XcodeConfig
struct XcodeConfig: Codable {
    var userDataPath: String?
}

// MARK: - ShellHistory
struct ShellHistory: Codable {
    var zshHistory: String?
    var bashHistory: String?

    enum CodingKeys: String, CodingKey {
        case zshHistory = "zsh_history"
        case bashHistory = "bash_history"
    }
}
