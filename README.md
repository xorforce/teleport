# Teleport

Teleport helps you migrate all your Mac settings, packages, dotfiles, and configurations from one Mac to another. Export everything to a `.teleport` archive and import it on your new Mac.

## Features

- CLI framework with `export` and `import` commands
- SwiftUI Mac app with navigation structure
- Category-based organization (8 categories defined)
- Shared manifest schema (Go & Swift)
- Basic export/import file handling

## Installation

### Via Homebrew (Recommended)

```bash
# Install CLI
brew install xorforce/tap/teleport-cli

# Install macOS App
brew install --cask xorforce/tap/teleport
```

### Manual Download

Download the latest release from [GitHub Releases](https://github.com/xorforce/teleport/releases):

- **CLI**: `teleport-cli-darwin-arm64.tar.gz` (Apple Silicon) or `teleport-cli-darwin-amd64.tar.gz` (Intel)
- **App**: `Teleport.dmg`

### Build from Source

```bash
# Clone the repository
git clone https://github.com/xorforce/teleport.git
cd teleport

# Build CLI
cd teleport-cli
go build -o teleport .

# Build App (requires Xcode)
cd ../teleport-app
xcodebuild -project teleport-app.xcodeproj -scheme teleport-app -configuration Release
```

## Usage

### CLI

```bash
# Export your settings
teleport export -o my-settings.teleport

# Import settings
teleport import my-settings.teleport
```

### Mac App

1. Launch Teleport from Applications
2. Select categories to export
3. Click "Export Settings"
4. Transfer the `.teleport` file to your new Mac
5. Import on the new Mac

## Opening Unsigned App

The macOS app is not notarized with Apple. On first launch:

1. **Right-click** the app and select **Open**, then click **Open** again
2. Or run: `xattr -cr /Applications/teleport-app.app`
3. Or go to **System Settings > Privacy & Security** and click **Open Anyway**

## Project Structure

```text
teleport/
├── teleport-app/          # SwiftUI Mac application
├── teleport-cli/          # Go CLI application
├── scripts/               # Build scripts
└── README.md
```

## Requirements

- **CLI**: Go 1.21+
- **Mac App**: macOS 13.0+, Xcode 15.0+

## Development

### Prerequisites

```bash
# Install all development dependencies
make setup
```

This installs:

- **golangci-lint** - Go linter
- **swiftlint** - Swift/SwiftUI linter
- **swiftformat** - Swift formatter
- **pre-commit** - Git hooks manager

### Linting

```bash
# Run all linters
make lint

# Lint only Go code
make lint-go

# Lint only Swift code
make lint-swift

# Auto-fix lint issues where possible
make lint-fix

# Format all code
make fmt
```

### Testing

```bash
# Run all tests
make test

# Run Go tests with coverage
make test-go-coverage

# Run Swift tests
make test-swift
```

### Building

```bash
# Build everything
make build

# Build release versions
make build-release
```

### Pre-commit Hooks

Pre-commit hooks run automatically on every commit to catch issues early:

```bash
# Install hooks (done automatically by make setup)
pre-commit install

# Run hooks manually on all files
make pre-commit
```

### Available Make Targets

```bash
make help  # Show all available targets
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Install dev dependencies: `make setup`
4. Make your changes
5. Run linters: `make lint`
6. Run tests: `make test`
7. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.
