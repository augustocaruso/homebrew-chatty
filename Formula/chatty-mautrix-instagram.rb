# frozen_string_literal: true

# Builds the Instagram entrypoint with the ordered Chatty patch set.
class ChattyMautrixInstagram < Formula
  desc "Instagram Matrix bridge with Chatty patches"
  homepage "https://github.com/mautrix/meta"
  url "https://github.com/mautrix/meta/archive/refs/tags/v0.2610.0.tar.gz"
  sha256 "6fbf706e65c35ea455a01736670feca52a548ec102cbd3949f536fa3d2c29ae2"
  license "AGPL-3.0-or-later"

  depends_on "go" => :build
  depends_on :macos

  # Publish these exact reviewed bytes, not a GitHub-generated source archive (PUBLISHING.md).
  resource "chatty-patches" do
    url "https://github.com/augustocaruso/homebrew-chatty/releases/download/patches-2026.11.14/chatty-patches-2026.11.14.tar.gz"
    sha256 "b0bc343f1af4ccb7270b7bd95ec3554e7a1f8d9e713850f6d871e0fa34752fc6"
  end

  def install
    resource("chatty-patches").stage buildpath/"chatty-patches"
    patches = buildpath/"chatty-patches/mautrix-meta"
    %w[
      thread-backfill-pagination.patch
      backfill-since.patch
      portal-creation-window.patch
      ghost-profile-name-stability.patch
    ].each do |patch|
      system "git", "apply", patches/patch
    end

    ENV["CGO_ENABLED"] = "1"
    ENV["GOTOOLCHAIN"] = "local"
    ENV["GOMAXPROCS"] = "2"
    ENV["GOFLAGS"] = "-mod=readonly"
    ENV["SOURCE_DATE_EPOCH"] = "1792163004"
    system "go", "test", "-p", "2", "-count=1", "-tags", "goolm", "./pkg/igconnector"
    system "go", "vet", "-p", "2", "-tags", "goolm", "./pkg/igconnector"
    ldflags = "-X main.Tag=v0.2610.0 -X main.Commit=3c16226686c71af64df294df0803791685064e0b " \
              "-X main.BuildTime=2026-10-16T15:03:24Z"
    system "go", "build", "-p", "2", "-trimpath", "-tags", "goolm", "-ldflags", ldflags,
           "-o", "mautrix-instagram", "./cmd/mautrix-instagram"
    bin.install "mautrix-instagram"
  end

  def caveats
    <<~EOS
      This builds mautrix-instagram, not the Messenger binary mautrix-meta.
      Chatty patches are included; the upstream version banner does not identify them.
      This installs only the binary, without configuration, pairing, appservice
      registration or service startup. See patches/README.md and PUBLISHING.md
      in augustocaruso/homebrew-chatty for provenance and source obligations.
    EOS
  end

  test do
    assert_match "mautrix-instagram", shell_output("#{bin}/mautrix-instagram --version")
  end
end
