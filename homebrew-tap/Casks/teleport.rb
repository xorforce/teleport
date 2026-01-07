cask "teleport" do
  version "0.1.0"
  sha256 "PLACEHOLDER_APP_SHA256"

  url "https://github.com/xorforce/teleport/releases/download/v#{version}/Teleport.dmg"
  name "Teleport"
  desc "Export and import macOS settings, packages, and configurations"
  homepage "https://github.com/xorforce/teleport"

  depends_on macos: ">= :ventura"

  app "teleport-app.app"

  zap trash: [
    "~/Library/Application Support/teleport-app",
    "~/Library/Caches/teleport-app",
    "~/Library/Preferences/com.xorforce.teleport-app.plist",
  ]

  caveats <<~EOS
    This app is not notarized. On first launch, you may need to:
    1. Right-click the app and select "Open"
    2. Or run: xattr -cr /Applications/teleport-app.app
    3. Or allow it in System Settings > Privacy & Security
  EOS
end

