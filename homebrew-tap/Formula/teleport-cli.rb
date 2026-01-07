class TeleportCli < Formula
  desc "CLI tool to export and import macOS settings, packages, and configurations"
  homepage "https://github.com/xorforce/teleport"
  version "0.0.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/xorforce/teleport/releases/download/v#{version}/teleport-cli-darwin-arm64.tar.gz"
      sha256 "d918a959c5485eb8d54e6a2cfe0346debd910fea3e25ad91ec1a22487ec64639"
    end
    on_intel do
      url "https://github.com/xorforce/teleport/releases/download/v#{version}/teleport-cli-darwin-amd64.tar.gz"
      sha256 "d995bd7085cd8532c28841151391e6901729552405e31ca8b34396906cada031"
    end
  end

  def install
    bin.install "teleport"
  end

  test do
    assert_match "Export macOS settings", shell_output("#{bin}/teleport --help")
  end
end

