# frozen_string_literal: true

# Builds Chatty's WhatsApp bridge and its patched whatsmeow dependency.
class ChattyMautrixWhatsapp < Formula
  desc "WhatsApp Matrix bridge with Chatty patches"
  homepage "https://github.com/mautrix/whatsapp"
  url "https://github.com/mautrix/whatsapp/archive/refs/tags/v0.2610.0.tar.gz"
  sha256 "c52a10be169e604626305077fd47b6de2e95612f4935c890e7b0752ee278b5a9"
  license "AGPL-3.0-or-later"

  depends_on "go" => :build
  depends_on :macos

  # Publish these exact reviewed bytes, not a GitHub-generated source archive (PUBLISHING.md).
  resource "chatty-patches" do
    url "https://github.com/augustocaruso/homebrew-chatty/releases/download/patches-2026.11.14/chatty-patches-2026.11.14.tar.gz"
    sha256 "b0bc343f1af4ccb7270b7bd95ec3554e7a1f8d9e713850f6d871e0fa34752fc6"
  end

  resource "whatsmeow" do
    url "https://github.com/tulir/whatsmeow/archive/0b0a1cdac3e2a20d1436127d860bfe0c2b8ac9de.tar.gz"
    sha256 "5f681469fd00acbe002d60aba5e7b8ab5bcdca742720f08e8dbbb61fb1668753"
  end

  def install
    resource("chatty-patches").stage buildpath/"chatty-patches"
    resource("whatsmeow").stage buildpath/"whatsmeow"
    patches = buildpath/"chatty-patches/mautrix-whatsapp"
    cd "whatsmeow" do
      system "git", "apply", patches/"whatsmeow/favorite-sticker-events.patch"
    end
    Dir.glob("#{patches}/*.patch").each do |patch|
      system "git", "apply", patch
    end

    ENV["CGO_ENABLED"] = "1"
    ENV["GOTOOLCHAIN"] = "local"
    ENV["GOMAXPROCS"] = "2"
    ENV["GOFLAGS"] = "-mod=readonly"
    ENV["SOURCE_DATE_EPOCH"] = "1792163004"
    system "go", "mod", "edit", "-replace=go.mau.fi/whatsmeow=#{buildpath}/whatsmeow"
    cd "whatsmeow" do
      system "go", "test", "-p", "2", "-count=1", "./..."
      system "go", "test", "-race", "-p", "2", "-count=1", "./..."
      system "go", "vet", "-p", "2", "./..."
    end
    system "go", "test", "-p", "2", "-count=1", "-tags", "goolm", "./..."
    system "go", "test", "-race", "-p", "2", "-count=1", "-tags", "goolm", "./..."
    system "go", "vet", "-p", "2", "-tags", "goolm", "./..."
    ldflags = "-X main.Tag=v0.2610.0 -X main.Commit=1067291a89f4949887b328104005abe4f7163ddf " \
              "-X main.BuildTime=2026-10-16T15:03:24Z"
    system "go", "build", "-p", "2", "-trimpath", "-tags", "goolm", "-ldflags", ldflags,
           "-o", "mautrix-whatsapp", "./cmd/mautrix-whatsapp"
    bin.install "mautrix-whatsapp"
  end

  def caveats
    <<~EOS
      Chatty patches are included; the upstream version banner does not identify them.
      This installs only the binary, without configuration, pairing, appservice
      registration or service startup. See patches/README.md and PUBLISHING.md
      in augustocaruso/homebrew-chatty for provenance and source obligations.
    EOS
  end

  test do
    assert_match "mautrix-whatsapp", shell_output("#{bin}/mautrix-whatsapp --version")
  end
end
