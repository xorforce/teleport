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

        try saveManifest(manifest, to: archiveURL)
        progress(0.2, "Saved manifest...")

        // Additional export logic will be implemented in subsequent phases
        progress(1.0, "Export complete!")

        return archiveURL
    }

    func importArchive(from url: URL, progress: @escaping (Double, String) -> Void) async throws {
        progress(0.1, "Reading archive...")

        let manifest = try loadManifest(from: url)
        progress(0.2, "Loaded manifest (version \(manifest.version))...")

        // Additional import logic will be implemented in subsequent phases
        progress(1.0, "Import complete!")
    }
}
