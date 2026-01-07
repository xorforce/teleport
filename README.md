# Teleport

Teleport helps you migrate all your Mac settings, packages, dotfiles, and configurations from one Mac to another. Export everything to a `.teleport` archive and import it on your new Mac.

## Features by Branch

### Phase-1: Foundation and Core Infrastructure ✅

**Available:**
- CLI framework with `export` and `import` commands
- SwiftUI Mac app with navigation structure
- Category-based organization (8 categories defined)
- Shared manifest schema (Go & Swift)
- Basic export/import file handling

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

