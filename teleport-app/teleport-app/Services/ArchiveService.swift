//
//  ArchiveService.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import Foundation

class ArchiveService {
    static let shared = ArchiveService()
    
    private init() {}
    
    func createArchiveDirectory(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
    
    func saveManifest(_ manifest: Manifest, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(manifest)
        let manifestURL = url.appendingPathComponent("manifest.json")
        try data.write(to: manifestURL)
    }
    
    func loadManifest(from url: URL) throws -> Manifest {
        let manifestURL = url.appendingPathComponent("manifest.json")
        let data = try Data(contentsOf: manifestURL)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Manifest.self, from: data)
    }
    
    func exportArchive(manifest: Manifest, selectedCategories: Set<Category>, progress: @escaping (Double, String) -> Void) async throws -> URL {
        var manifest = manifest
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let timestamp = formatter.string(from: Date())
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let archiveName = "teleport-export-\(timestamp).teleport"
        let archiveURL = documentsPath.appendingPathComponent(archiveName)
        
        // Remove existing archive if it exists
        if FileManager.default.fileExists(atPath: archiveURL.path) {
            try FileManager.default.removeItem(at: archiveURL)
        }
        
        try createArchiveDirectory(at: archiveURL)
        progress(0.1, "Creating archive structure...")
        
        // Detect and export Homebrew
        if selectedCategories.contains(.homebrew) {
            progress(0.2, "Detecting Homebrew packages...")
            if let homebrew = await HomebrewService.shared.detectHomebrew() {
                manifest.homebrew = homebrew
                
                // Save Brewfile
                if !homebrew.brewfile.isEmpty {
                    let brewfileDir = archiveURL.appendingPathComponent("homebrew")
                    try FileManager.default.createDirectory(at: brewfileDir, withIntermediateDirectories: true)
                    try homebrew.brewfile.write(to: brewfileDir.appendingPathComponent("Brewfile"), atomically: true, encoding: .utf8)
                }
            }
        }
        
        // Detect and export Node packages
        if selectedCategories.contains(.nodePackages) {
            progress(0.4, "Detecting Node package managers...")
            let nodePackages = await NodePackageService.shared.detectNodePackages()
            manifest.nodePackages = nodePackages
            
            // Save Node package files
            let nodeDir = archiveURL.appendingPathComponent("npm")
            try FileManager.default.createDirectory(at: nodeDir, withIntermediateDirectories: true)
            
            if let npm = nodePackages.npm, !npm.isEmpty {
                try saveNodePackages(npm, to: archiveURL.appendingPathComponent("npm/global-packages.json"))
            }
            if let bun = nodePackages.bun, !bun.isEmpty {
                try saveNodePackages(bun, to: archiveURL.appendingPathComponent("bun/global-packages.json"))
            }
            if let pnpm = nodePackages.pnpm, !pnpm.isEmpty {
                try saveNodePackages(pnpm, to: archiveURL.appendingPathComponent("pnpm/global-packages.json"))
            }
            if let yarn = nodePackages.yarn, !yarn.isEmpty {
                try saveNodePackages(yarn, to: archiveURL.appendingPathComponent("yarn/global-packages.json"))
            }
        }
        
        // Detect and export Mise
        if selectedCategories.contains(.mise) {
            progress(0.6, "Detecting Mise tools...")
            if let mise = await MiseService.shared.detectMise() {
                manifest.mise = mise
                
                let miseDir = archiveURL.appendingPathComponent("mise")
                try FileManager.default.createDirectory(at: miseDir, withIntermediateDirectories: true)
                
                if let configFile = mise.configFile {
                    try configFile.write(to: miseDir.appendingPathComponent("config.toml"), atomically: true, encoding: .utf8)
                }
                if let toolVersions = mise.toolVersions {
                    try toolVersions.write(to: miseDir.appendingPathComponent(".tool-versions"), atomically: true, encoding: .utf8)
                }
            }
        }
        
        // Save manifest
        progress(0.9, "Saving manifest...")
        try saveManifest(manifest, to: archiveURL)
        
        progress(1.0, "Export complete!")
        
        return archiveURL
    }
    
    private func saveNodePackages(_ packages: [PackageInfo], to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(packages)
        try data.write(to: url)
    }
    
    func importArchive(from url: URL, progress: @escaping (Double, String) -> Void) async throws {
        progress(0.1, "Reading archive...")
        
        let manifest = try loadManifest(from: url)
        progress(0.2, "Loaded manifest (version \(manifest.version))...")
        
        // Additional import logic will be implemented in subsequent phases
        progress(1.0, "Import complete!")
    }
}

