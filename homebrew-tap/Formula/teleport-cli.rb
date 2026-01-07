class TeleportCli < Formula
  desc "CLI tool to export and import macOS settings, packages, and configurations"
  homepage "https://github.com/xorforce/teleport"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/xorforce/teleport/releases/download/v#{version}/teleport-cli-darwin-arm64.tar.gz"
      sha256 "PLACEHOLDER_ARM64_SHA256"
    end
    on_intel do
      url "https://github.com/xorforce/teleport/releases/download/v#{version}/teleport-cli-darwin-amd64.tar.gz"
      sha256 "PLACEHOLDER_AMD64_SHA256"
    end
  end

  def install
    bin.install "teleport"
  end

  test do
    assert_match "Export macOS settings", shell_output("#{bin}/teleport --help")
  end
end

