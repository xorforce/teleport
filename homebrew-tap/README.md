# Homebrew Tap for Teleport

This is the official Homebrew tap for [Teleport](https://github.com/xorforce/teleport).

## Installation

### CLI

```bash
brew tap xorforce/teleport https://github.com/xorforce/teleport
brew install xorforce/teleport/teleport-cli
```

### macOS App

```bash
brew tap xorforce/teleport https://github.com/xorforce/teleport
brew install --cask xorforce/teleport/teleport
```

### Both

```bash
brew tap xorforce/teleport https://github.com/xorforce/teleport
brew install xorforce/teleport/teleport-cli
brew install --cask xorforce/teleport/teleport
```

## Updating

```bash
brew update
brew upgrade teleport-cli
brew upgrade --cask teleport
```

## Uninstalling

```bash
brew uninstall teleport-cli
brew uninstall --cask teleport
brew untap xorforce/teleport
```

## Note on Unsigned App

The macOS app is not notarized with Apple. On first launch, you may see a security warning. To open:

1. **Right-click** the app in Applications and select **Open**
2. Or run: `xattr -cr /Applications/teleport-app.app`
3. Or go to **System Settings > Privacy & Security** and click **Open Anyway**

