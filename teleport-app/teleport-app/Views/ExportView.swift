//
//  ExportView.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import SwiftUI

struct ExportDialogView: View {
    @ObservedObject var exportState: ExportState
    @Environment(\.dismiss) var dismiss
    @State private var isExporting = false
    @State private var showingSuccessAlert = false
    @State private var exportError: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Export Settings")
                .font(.title2)
                .bold()

            Text("This will create a .teleport archive containing all selected categories.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            if isExporting {
                ProgressView(value: exportState.exportProgress) {
                    Text(exportState.currentOperation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                List {
                    Section("Selected Categories") {
                        ForEach(Array(exportState.selectedCategories).sorted(by: { $0.rawValue < $1.rawValue })) { category in

                            Label(category.rawValue, systemImage: category.icon)
                                .padding(2)
                        }
                    }
                }
                .listRowSeparator(.automatic)
                .frame(height: 200)
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                .disabled(isExporting)

                Button("Export") {
                    Task {
                        await performExport()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(isExporting)
            }
        }
        .padding()
        .frame(width: 500, height: 400)
        .alert("Export Complete", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            if let path = exportState.exportPath {
                Text("Settings exported to:\n\(path.lastPathComponent)")
            }
        }
        .alert("Export Error", isPresented: .constant(exportError != nil)) {
            Button("OK") {
                exportError = nil
            }
        } message: {
            if let error = exportError {
                Text(error)
            }
        }
    }

    private func performExport() async {
        isExporting = true
        exportState.isExporting = true

        do {
            let archiveURL = try await ArchiveService.shared.exportArchive(
                manifest: exportState.manifest,
                selectedCategories: exportState.selectedCategories
            ) { progress, operation in
                DispatchQueue.main.async {
                    exportState.exportProgress = progress
                    exportState.currentOperation = operation
                }
            }

            DispatchQueue.main.async {
                exportState.exportPath = archiveURL
                exportState.isExporting = false
                isExporting = false
                showingSuccessAlert = true
            }
        } catch {
            DispatchQueue.main.async {
                exportState.isExporting = false
                isExporting = false
                exportError = error.localizedDescription
            }
        }
    }
}

#Preview {
    ExportDialogView(exportState: ExportState())
}
