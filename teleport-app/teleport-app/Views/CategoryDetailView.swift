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
        .navigationBarTitleDisplayMode(.inline)
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

// Category detail views
struct HomebrewView: View {
    @ObservedObject var exportState: ExportState
    @State private var homebrew: Homebrew?
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isLoading {
                ProgressView("Detecting Homebrew packages...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if let homebrew = homebrew {
                if let packages = homebrew.packages, !packages.isEmpty {
                    Text("\(packages.count) packages detected")
                        .font(.headline)
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(packages, id: \.self) { package in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(package)
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                } else {
                    Text("No Homebrew packages detected")
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Homebrew not installed or not detected")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            isLoading = true
            homebrew = await HomebrewService.shared.detectHomebrew()
            isLoading = false
        }
    }
}

struct NodePackagesView: View {
    @ObservedObject var exportState: ExportState
    @State private var nodePackages: NodePackages?
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isLoading {
                ProgressView("Detecting Node packages...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if let nodePackages = nodePackages {
                let totalCount = (nodePackages.npm?.count ?? 0) +
                                (nodePackages.bun?.count ?? 0) +
                                (nodePackages.pnpm?.count ?? 0) +
                                (nodePackages.yarn?.count ?? 0)
                
                if totalCount > 0 {
                    Text("\(totalCount) packages detected across package managers")
                        .font(.headline)
                    
                    if let npm = nodePackages.npm, !npm.isEmpty {
                        PackageManagerSection(title: "npm", packages: npm)
                    }
                    if let bun = nodePackages.bun, !bun.isEmpty {
                        PackageManagerSection(title: "bun", packages: bun)
                    }
                    if let pnpm = nodePackages.pnpm, !pnpm.isEmpty {
                        PackageManagerSection(title: "pnpm", packages: pnpm)
                    }
                    if let yarn = nodePackages.yarn, !yarn.isEmpty {
                        PackageManagerSection(title: "yarn", packages: yarn)
                    }
                } else {
                    Text("No Node packages detected")
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No Node package managers detected")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            isLoading = true
            nodePackages = await NodePackageService.shared.detectNodePackages()
            isLoading = false
        }
    }
}

struct PackageManagerSection: View {
    let title: String
    let packages: [PackageInfo]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.headline)
                .foregroundColor(.secondary)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(packages) { package in
                        HStack {
                            Image(systemName: "cube.fill")
                                .foregroundColor(.blue)
                            Text(package.name)
                                .font(.system(.body, design: .monospaced))
                            Spacer()
                            Text(package.version)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

struct MiseView: View {
    @ObservedObject var exportState: ExportState
    @State private var mise: Mise?
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isLoading {
                ProgressView("Detecting Mise tools...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if let mise = mise {
                if let tools = mise.tools, !tools.isEmpty {
                    Text("\(tools.count) tools detected")
                        .font(.headline)
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(tools.keys.sorted()), id: \.self) { tool in
                                HStack {
                                    Image(systemName: "wrench.and.screwdriver.fill")
                                        .foregroundColor(.orange)
                                    Text(tool)
                                        .font(.system(.body, design: .monospaced))
                                    Spacer()
                                    Text(tools[tool] ?? "")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                } else {
                    Text("No Mise tools detected")
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Mise not installed or not detected")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            isLoading = true
            mise = await MiseService.shared.detectMise()
            isLoading = false
        }
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

