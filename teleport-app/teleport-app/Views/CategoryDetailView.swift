//
//  CategoryDetailView.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import SwiftUI

struct CategoryDetailView: View {
    let category: Category
    @ObservedObject var exportState: ExportState
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                    VStack(alignment: .leading) {
                        Text(category.rawValue)
                            .font(.largeTitle)
                            .bold()
                        Text(category.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                
                Divider()
                
                // Selection toggle
                Toggle(isOn: Binding(
                    get: { exportState.selectedCategories.contains(category) },
                    set: { _ in exportState.toggleCategory(category) }
                )) {
                    Text("Include in export")
                        .font(.headline)
                }
                .padding(.horizontal)
                
                Divider()
                
                // Category-specific content
                categoryContent
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(category.rawValue)
    }
    
    @ViewBuilder
    private var categoryContent: some View {
        switch category {
        case .homebrew:
            HomebrewView(exportState: exportState)
        case .nodePackages:
            NodePackagesView(exportState: exportState)
        case .mise:
            MiseView(exportState: exportState)
        case .dotfiles:
            DotfilesView(exportState: exportState)
        case .macSettings:
            MacSettingsView(exportState: exportState)
        case .ide:
            IDEView(exportState: exportState)
        case .fonts:
            FontsView(exportState: exportState)
        case .shellHistory:
            ShellHistoryView(exportState: exportState)
        }
    }
}

// Placeholder views for each category (will be implemented in subsequent phases)
struct HomebrewView: View {
    @ObservedObject var exportState: ExportState
    var body: some View {
        Text("Homebrew detection will be implemented in Phase 2")
            .foregroundColor(.secondary)
    }
}

struct NodePackagesView: View {
    @ObservedObject var exportState: ExportState
    var body: some View {
        Text("Node package manager detection will be implemented in Phase 2")
            .foregroundColor(.secondary)
    }
}

struct MiseView: View {
    @ObservedObject var exportState: ExportState
    var body: some View {
        Text("Mise detection will be implemented in Phase 2")
            .foregroundColor(.secondary)
    }
}

struct DotfilesView: View {
    @ObservedObject var exportState: ExportState
    var body: some View {
        Text("Dotfile detection will be implemented in Phase 3")
            .foregroundColor(.secondary)
    }
}

struct MacSettingsView: View {
    @ObservedObject var exportState: ExportState
    var body: some View {
        Text("macOS settings detection will be implemented in Phase 4")
            .foregroundColor(.secondary)
    }
}

struct IDEView: View {
    @ObservedObject var exportState: ExportState
    var body: some View {
        Text("IDE profile detection will be implemented in Phase 5")
            .foregroundColor(.secondary)
    }
}

struct FontsView: View {
    @ObservedObject var exportState: ExportState
    var body: some View {
        Text("Font detection will be implemented in Phase 5")
            .foregroundColor(.secondary)
    }
}

struct ShellHistoryView: View {
    @ObservedObject var exportState: ExportState
    var body: some View {
        Text("Shell history detection will be implemented in Phase 3")
            .foregroundColor(.secondary)
    }
}

#Preview {
    NavigationStack {
        CategoryDetailView(
            category: .homebrew,
            exportState: ExportState()
        )
    }
}
