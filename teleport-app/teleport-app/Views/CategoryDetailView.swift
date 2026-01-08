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
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(category.color.opacity(0.15))
                            .frame(width: 56, height: 56)
                        Image(systemName: category.icon)
                            .font(.system(size: 26))
                            .foregroundStyle(category.color)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.rawValue)
                            .font(.title)
                            .fontWeight(.semibold)
                        Text(category.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()

                    // Export toggle pill
                    Toggle(isOn: Binding(
                        get: { exportState.selectedCategories.contains(category) },
                        set: { _ in exportState.toggleCategory(category) }
                    )) {
                        Text("Export")
                            .font(.subheadline.weight(.medium))
                    }
                    .toggleStyle(.switch)
                    .tint(category.color)
                }
                .padding(.horizontal, 4)

                // Category-specific content
                categoryContent
            }
            .padding()
        }
        .background(Color(nsColor: .windowBackgroundColor))
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

// MARK: - Homebrew View
struct HomebrewView: View {
    @ObservedObject var exportState: ExportState
    @State private var homebrew: Homebrew?
    @State private var isLoading = true  // Start with loading state
    @State private var searchText = ""
    @State private var selectedTab = 0

    private var filteredFormulae: [String] {
        guard let packages = homebrew?.packages else { return [] }
        if searchText.isEmpty { return packages }
        return packages.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    private var filteredCasks: [String] {
        guard let casks = homebrew?.casks else { return [] }
        if searchText.isEmpty { return casks }
        return casks.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    private var formulaeCount: Int { homebrew?.packages?.count ?? 0 }
    private var casksCount: Int { homebrew?.casks?.count ?? 0 }
    private var totalCount: Int { formulaeCount + casksCount }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isLoading {
                loadingView
            } else if let homebrew = homebrew, totalCount > 0 {
                // Stats cards
                statsCardsView

                // Search bar
                searchBarView

                // Tab picker
                Picker("Package Type", selection: $selectedTab) {
                    Text("Formulae (\(formulaeCount))").tag(0)
                    Text("Casks (\(casksCount))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 4)

                // Package list
                if selectedTab == 0 {
                    packageListView(
                        packages: filteredFormulae,
                        icon: "terminal.fill",
                        color: .green,
                        emptyMessage: searchText.isEmpty
                            ? "No formulae installed" : "No formulae match '\(searchText)'"
                    )
                } else {
                    packageListView(
                        packages: filteredCasks,
                        icon: "macwindow",
                        color: .blue,
                        emptyMessage: searchText.isEmpty
                            ? "No casks installed" : "No casks match '\(searchText)'"
                    )
                }
            } else {
                emptyStateView
            }
        }
        .task {
            isLoading = true
            homebrew = await HomebrewService.shared.detectHomebrew()
            isLoading = false
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Scanning Homebrew packages...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var statsCardsView: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Total Packages",
                value: "\(totalCount)",
                icon: "shippingbox.fill",
                color: .orange
            )
            StatCard(
                title: "Formulae",
                value: "\(formulaeCount)",
                icon: "terminal.fill",
                color: .green
            )
            StatCard(
                title: "Casks",
                value: "\(casksCount)",
                icon: "macwindow",
                color: .blue
            )
        }
    }

    private var searchBarView: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search packages...", text: $searchText)
                .textFieldStyle(.plain)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }

    private func packageListView(
        packages: [String],
        icon: String,
        color: Color,
        emptyMessage: String
    ) -> some View {
        Group {
            if packages.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.title)
                        .foregroundStyle(.tertiary)
                    Text(emptyMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 180, maximum: 250), spacing: 10)
                        ],
                        spacing: 10
                    ) {
                        ForEach(packages, id: \.self) { package in
                            PackageCard(name: package, icon: icon, color: color)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 400)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "mug")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text("Homebrew not detected")
                .font(.headline)
            Text("Install Homebrew to manage packages")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct PackageCard: View {
    let name: String
    let icon: String
    let color: Color
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.15))
                .cornerRadius(6)
            Text(name)
                .font(.system(.body, design: .monospaced))
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isHovered ? Color.primary.opacity(0.05) : Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Node Packages View
struct NodePackagesView: View {
    @ObservedObject var exportState: ExportState
    @State private var nodePackages: NodePackages?
    @State private var isLoading = true  // Start with loading state
    @State private var searchText = ""

    private var npmCount: Int { nodePackages?.npm?.count ?? 0 }
    private var bunCount: Int { nodePackages?.bun?.count ?? 0 }
    private var pnpmCount: Int { nodePackages?.pnpm?.count ?? 0 }
    private var yarnCount: Int { nodePackages?.yarn?.count ?? 0 }
    private var totalCount: Int { npmCount + bunCount + pnpmCount + yarnCount }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Scanning Node packages...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else if totalCount > 0 {
                // Stats cards
                HStack(spacing: 12) {
                    StatCard(title: "Total", value: "\(totalCount)", icon: "cube.fill", color: .green)
                    if npmCount > 0 {
                        StatCard(title: "npm", value: "\(npmCount)", icon: "cube.box.fill", color: .red)
                    }
                    if bunCount > 0 {
                        StatCard(title: "bun", value: "\(bunCount)", icon: "hare.fill", color: .orange)
                    }
                }

                // Search bar
                SearchBar(text: $searchText, placeholder: "Search packages...")

                // Package sections
                ScrollView {
                    VStack(spacing: 16) {
                        if let npm = nodePackages?.npm, !npm.isEmpty {
                            PackageManagerSection(
                                title: "npm",
                                packages: filterPackages(npm),
                                color: .red
                            )
                        }
                        if let bun = nodePackages?.bun, !bun.isEmpty {
                            PackageManagerSection(
                                title: "bun",
                                packages: filterPackages(bun),
                                color: .orange
                            )
                        }
                        if let pnpm = nodePackages?.pnpm, !pnpm.isEmpty {
                            PackageManagerSection(
                                title: "pnpm",
                                packages: filterPackages(pnpm),
                                color: .yellow
                            )
                        }
                        if let yarn = nodePackages?.yarn, !yarn.isEmpty {
                            PackageManagerSection(
                                title: "yarn",
                                packages: filterPackages(yarn),
                                color: .blue
                            )
                        }
                    }
                }
                .frame(maxHeight: 400)
            } else {
                EmptyStateView(
                    icon: "cube",
                    title: "No Node packages detected",
                    subtitle: "Install npm, bun, pnpm, or yarn global packages"
                )
            }
        }
        .task {
            isLoading = true
            nodePackages = await NodePackageService.shared.detectNodePackages()
            isLoading = false
        }
    }

    private func filterPackages(_ packages: [PackageInfo]) -> [PackageInfo] {
        if searchText.isEmpty { return packages }
        return packages.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

struct PackageManagerSection: View {
    let title: String
    let packages: [PackageInfo]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(color)
                Text("(\(packages.count))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            if packages.isEmpty {
                Text("No matches")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .padding(.vertical, 8)
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 200, maximum: 300), spacing: 10)],
                    spacing: 8
                ) {
                    ForEach(packages) { package in
                        NodePackageCard(package: package, color: color)
                    }
                }
            }
        }
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct NodePackageCard: View {
    let package: PackageInfo
    let color: Color
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "cube.fill")
                .font(.system(size: 12))
                .foregroundStyle(color)
            Text(package.name)
                .font(.system(.callout, design: .monospaced))
                .lineLimit(1)
            Spacer()
            Text(package.version)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.primary.opacity(0.05))
                .cornerRadius(4)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(isHovered ? Color.primary.opacity(0.05) : Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Mise View
struct MiseView: View {
    @ObservedObject var exportState: ExportState
    @State private var mise: Mise?
    @State private var isLoading = true  // Start with loading state
    @State private var searchText = ""

    private var tools: [String: String] { mise?.tools ?? [:] }
    private var filteredTools: [(String, String)] {
        let sorted = tools.sorted { $0.key < $1.key }
        if searchText.isEmpty { return sorted.map { ($0.key, $0.value) } }
        return sorted.filter { $0.key.localizedCaseInsensitiveContains(searchText) }
            .map { ($0.key, $0.value) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Scanning Mise tools...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else if !tools.isEmpty {
                // Stats
                HStack(spacing: 12) {
                    StatCard(
                        title: "Tools Managed",
                        value: "\(tools.count)",
                        icon: "wrench.and.screwdriver.fill",
                        color: .purple
                    )
                }

                // Search
                SearchBar(text: $searchText, placeholder: "Search tools...")

                // Tools grid
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 180, maximum: 250), spacing: 10)],
                        spacing: 10
                    ) {
                        ForEach(filteredTools, id: \.0) { tool, version in
                            ToolCard(name: tool, version: version)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 400)
            } else {
                EmptyStateView(
                    icon: "wrench.and.screwdriver",
                    title: "Mise not detected",
                    subtitle: "Install mise to manage runtime versions"
                )
            }
        }
        .task {
            isLoading = true
            mise = await MiseService.shared.detectMise()
            isLoading = false
        }
    }
}

struct ToolCard: View {
    let name: String
    let version: String
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 14))
                .foregroundStyle(.purple)
                .frame(width: 28, height: 28)
                .background(Color.purple.opacity(0.15))
                .cornerRadius(6)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1)
                Text(version)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isHovered ? Color.primary.opacity(0.05) : Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .onHover { isHovered = $0 }
    }
}

// MARK: - Shared Components
struct SearchBar: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Placeholder Views
struct DotfilesView: View {
    @ObservedObject var exportState: ExportState
    var body: some View {
        EmptyStateView(
            icon: "doc.text",
            title: "Coming Soon",
            subtitle: "Dotfile detection will be implemented in Phase 3"
        )
    }
}

struct MacSettingsView: View {
    @ObservedObject var exportState: ExportState
    var body: some View {
        EmptyStateView(
            icon: "gearshape",
            title: "Coming Soon",
            subtitle: "macOS settings detection will be implemented in Phase 4"
        )
    }
}

struct IDEView: View {
    @ObservedObject var exportState: ExportState
    var body: some View {
        EmptyStateView(
            icon: "applescript",
            title: "Coming Soon",
            subtitle: "IDE profile detection will be implemented in Phase 5"
        )
    }
}

struct FontsView: View {
    @ObservedObject var exportState: ExportState
    var body: some View {
        EmptyStateView(
            icon: "textformat",
            title: "Coming Soon",
            subtitle: "Font detection will be implemented in Phase 5"
        )
    }
}

struct ShellHistoryView: View {
    @ObservedObject var exportState: ExportState
    var body: some View {
        EmptyStateView(
            icon: "terminal",
            title: "Coming Soon",
            subtitle: "Shell history detection will be implemented in Phase 3"
        )
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
