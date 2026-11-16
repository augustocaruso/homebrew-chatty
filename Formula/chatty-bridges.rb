# frozen_string_literal: true

# Packages the reviewed Chatty CLI source snapshot, not Beeper's bbctl.
class ChattyBridges < Formula
  desc "Manage native Chatty Matrix bridges"
  homepage "https://github.com/augustocaruso/bridge-manager"
  # Published source snapshot: 685172c3a8de35b86d29bac58d357032acaf7937 (PUBLISHING.md).
  url "https://github.com/augustocaruso/bridge-manager/releases/download/chatty-2026.11.16/chatty-bridges-2026.11.16.tar.gz"
  sha256 "329849d3f57bf8a8e3116204bb4090a1806917b49012b495e2607392e2ed4832"
  license "Apache-2.0"

  depends_on "go" => :build
  depends_on :macos

  def install
    ENV["GOMAXPROCS"] = "2"
    ENV["GOTOOLCHAIN"] = "local"
    ENV["GOFLAGS"] = "-mod=readonly"
    system "go", "build", "-p", "2", "-trimpath", "-o", "chatty-bridges",
           "github.com/beeper/bridge-manager/cmd/chatty-bridges"
    bin.install "chatty-bridges"
  end

  def caveats
    <<~EOS
      This installs only the CLI and never invokes its install, register or service
      commands. No service is registered or started. Values come from flags or
      ~/Library/Application Support/Chatty/machine.json; --version and --help are
      safe checks, not backend health checks.
      The CLI banner is 0.1.0; the package version identifies the source snapshot.
    EOS
  end

  test do
    assert_match "chatty-bridges version 0.1.0", shell_output("#{bin}/chatty-bridges --version")
  end
end
