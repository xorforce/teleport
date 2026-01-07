# Teleport

Teleport helps you migrate all your Mac settings, packages, dotfiles, and configurations from one Mac to another. Export everything to a `.teleport` archive and import it on your new Mac.

## Features by Branch

### Phase-1: Foundation and Core Infrastructure ✅

**Available Features:**
- CLI framework with `export` and `import` commands
- SwiftUI Mac app with navigation structure
- Category-based organization (8 categories defined)
- Shared manifest schema (Go & Swift)
- Basic export/import file handling

**What Works:**
- CLI: `teleport export` and `teleport import` commands
- GUI: Category sidebar navigation and selection
- Archive directory creation

---

### Phase-2: Package Manager Detection and Export

**Status:** Not yet merged

**Planned Features:**
- Homebrew package detection and Brewfile export
- Node package manager detection (npm, bun, pnpm, yarn)
- Mise tool version detection

---

### Phase-3: Dotfiles and Shell Configuration

**Status:** Not yet merged

**Planned Features:**
- Dotfile detection and export (.zshrc, .gitconfig, etc.)
- Shell history export with privacy options

---

### Phase-4: macOS System Settings

**Status:** Not yet merged

**Planned Features:**
- macOS defaults detection and export
- System preferences migration

---

### Phase-5: IDE Profiles and Fonts

**Status:** Not yet merged

**Planned Features:**
- VS Code, Cursor, and Xcode configuration export
- User-installed font detection and export

---

### Phase-6: Import and Restore Engine

**Status:** Not yet merged

**Planned Features:**
- Full import functionality with conflict resolution
- Category-based selective import

---

### Phase-7: Polish and Release

**Status:** Not yet merged

**Planned Features:**
- Enhanced error handling
- User onboarding flow
- Documentation improvements

---

## Quick Start

### CLI

```bash
# Build the CLI
cd teleport-cli
go build -o teleport .

# Export your settings
./teleport export -o my-settings.teleport

# Import settings
./teleport import my-settings.teleport
```

### Mac App

1. Open `teleport-app/teleport-app.xcodeproj` in Xcode
2. Build and run (⌘R)
3. Select categories and click "Export Settings"

## Project Structure

```
teleport/
├── teleport-app/          # SwiftUI Mac application
├── teleport-cli/         # Go CLI application
└── README.md             # This file
```

## Requirements

- **CLI**: Go 1.21+
- **Mac App**: macOS 13.0+, Xcode 15.0+

---

*This README is updated as features are added to each branch.*

