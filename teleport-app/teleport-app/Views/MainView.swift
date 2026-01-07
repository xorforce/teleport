//
//  MainView.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import SwiftUI

struct MainView: View {
    @StateObject private var exportState = ExportState()
    @State private var selectedCategory: Category? = nil
    @State private var showingExportDialog = false
    
    var body: some View {
        NavigationSplitView {
            // Sidebar with categories
            List(selection: $selectedCategory) {
                Section("Categories") {
                    ForEach(Category.allCases) { category in
                        NavigationLink(value: category) {
                            Label {
                                Text(category.rawValue)
                            } icon: {
                                Image(systemName: category.icon)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Teleport")
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            if let category = selectedCategory {
                CategoryDetailView(category: category, exportState: exportState)
            } else {
                ContentPlaceholderView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingExportDialog = true
                }) {
                    Text("Export")
                        .padding(2)
                }
                .disabled(exportState.selectedCategories.isEmpty)
                .help(exportState.selectedCategories.isEmpty ? "Select at least one category to export" : "Export selected settings")
            }
        }
        .sheet(isPresented: $showingExportDialog) {
            ExportDialogView(exportState: exportState)
        }
    }
}

struct ContentPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Select a category to begin")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Choose a category from the sidebar to view and configure export options")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MainView()
}

