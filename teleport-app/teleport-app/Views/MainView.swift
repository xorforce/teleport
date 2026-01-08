//
//  MainView.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import SwiftUI

struct MainView: View {
    @StateObject private var exportState = ExportState()
    @State private var selectedCategory: Category?
    @State private var showingExportDialog = false

    var body: some View {
        NavigationSplitView {
            // Sidebar with categories
            List(selection: $selectedCategory) {
                Section("Categories") {
                    ForEach(Category.allCases) { category in
                        NavigationLink(value: category) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(category.color.opacity(0.15))
                                        .frame(width: 28, height: 28)
                                    Image(systemName: category.icon)
                                        .font(.system(size: 13))
                                        .foregroundStyle(category.color)
                                }
                                Text(category.rawValue)
                                    .font(.body)
                                Spacer()
                                if exportState.selectedCategories.contains(category) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Teleport")
            .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        } detail: {
            if let category = selectedCategory {
                CategoryDetailView(category: category, exportState: exportState)
            } else {
                ContentPlaceholderView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingExportDialog = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export")
                    }
                    .padding(.horizontal, 4)
                }
                .disabled(exportState.selectedCategories.isEmpty)
                .help(
                    exportState.selectedCategories.isEmpty
                        ? "Select at least one category to export"
                        : "Export \(exportState.selectedCategories.count) selected categories"
                )
            }
        }
        .sheet(isPresented: $showingExportDialog) {
            ExportDialogView(exportState: exportState)
        }
    }
}

struct ContentPlaceholderView: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
            }
            VStack(spacing: 8) {
                Text("Select a category")
                    .font(.title2.weight(.semibold))
                Text("Choose a category from the sidebar to view\nand configure export options")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview {
    MainView()
}
