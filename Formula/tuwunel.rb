# frozen_string_literal: true

# Builds the native Matrix server without provisioning a running instance.
class Tuwunel < Formula
  desc "High-performance Matrix homeserver"
  homepage "https://tuwunel.chat"
  url "https://github.com/matrix-construct/tuwunel/archive/refs/tags/v1.9.4.tar.gz"
  sha256 "44c0efde8d5a540a7e670fbc60975499273c6b9c14b45d96cf4789864cfc7554"
  license "Apache-2.0"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on :macos

  def install
    ENV["CARGO_BUILD_JOBS"] = "2"
    ENV["HOMEBREW_MAKE_JOBS"] = "2"
    ENV["CARGO_INCREMENTAL"] = "0"
    ENV["SOURCE_DATE_EPOCH"] = "1791625810"
    # Same release/default-feature build as the native builder, staged only into the keg.
    # See README.md for the cargo build versus cargo install equivalence proof.
    system "cargo", "install", *std_cargo_args(path: "src/main"), "--bin", "tuwunel"
  end

  def caveats
    <<~EOS
      This formula installs only the binary. It creates no configuration or database
      and registers or starts no service. Existing installations are not adopted.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tuwunel --version")
  end
end
