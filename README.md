# Chatty Homebrew Tap

Source-built macOS packages for a Matrix homeserver, Chatty's patched bridges,
and the Chatty bridge-management CLI. The tap name is `augustocaruso/chatty`;
its repository is `augustocaruso/homebrew-chatty`.

**Publication status:** the tap repository and its patches release are not yet
published. The `chatty-bridges` source release is public. The installation
commands below apply once the tap and patches asset are published and verified.
See [PUBLISHING.md](PUBLISHING.md) for exact sources, hashes and release steps.

| Formula | Installed binary | Source |
| --- | --- | --- |
| `tuwunel` | `tuwunel` | Tuwunel 1.9.4, upstream Cargo.lock, default features |
| `chatty-mautrix-whatsapp` | `mautrix-whatsapp` | mautrix WhatsApp 0.2610.0 with Chatty patches and patched whatsmeow |
| `chatty-mautrix-instagram` | `mautrix-instagram` | mautrix Meta 0.2610.0 with four Chatty patches; not the Messenger entrypoint |
| `chatty-bridges` | `chatty-bridges` | bridge-manager fork, tag `chatty-2026.11.16`, commit `685172c3a8de35b86d29bac58d357032acaf7937` |

## Installation

Once publication is complete:

```sh
brew tap augustocaruso/chatty
brew install augustocaruso/chatty/tuwunel
brew install augustocaruso/chatty/chatty-mautrix-whatsapp
brew install augustocaruso/chatty/chatty-mautrix-instagram
brew install augustocaruso/chatty/chatty-bridges
```

Install only the components you need. These are source builds, not bottles.
Homebrew supplies the declared build tools: Go for the CLI and bridges;
Rust, CMake and pkgconf for Tuwunel. No upstream module version is changed.

Installation only places binaries in the Homebrew prefix. There is no
`post_install` or `service` block, database or configuration creation, pairing,
appservice registration, service startup, adoption of an existing backend or
implicit `brew pin`. Installing a package does not switch a running backend.
Chatty-prefixed formula names distinguish patched builds from upstream packages,
but the binaries retain their upstream names. Resolve package conflicts before
installing another package that provides the same binary.

`chatty-bridges` uses neutral defaults. Per-machine values come from flags or
`~/Library/Application Support/Chatty/machine.json`; consult the source
repository's [README](https://github.com/augustocaruso/bridge-manager/blob/chatty-2026.11.16/README.md)
and [CHATTY.md](https://github.com/augustocaruso/bridge-manager/blob/chatty-2026.11.16/CHATTY.md).
Installation never invokes its administrative commands. `--version` and
`--help` are safe CLI checks, not backend health checks. Its version banner is
`chatty-bridges version 0.1.0`; the package version identifies the source snapshot.

## Repository Layout

- `Formula/`: Ruby source-build recipes with explicit URLs, SHA-256 hashes, build dependencies and offline version tests.
- `patches/`: Chatty's server patches, with [upstream bases, application order and a hash manifest](patches/README.md).
- `tools/package_patches.py`: deterministic release packaging using only the Python standard library; not used during formula installation.
- [PUBLISHING.md](PUBLISHING.md): source pins, release assets, hash verification and distribution obligations.

Commands in these documents run from the tap repository root. When working in
the Chatty application repository instead, first enter `Packaging/homebrew-chatty`.

## Reproduce and Verify the Patches Asset

Choose a new output path in a separate build directory:

```sh
export E="$(mktemp -d)"
uv run --no-project python tools/package_patches.py "$E/chatty-patches-2026.11.14.tar.gz"
shasum -a 256 "$E/chatty-patches-2026.11.14.tar.gz"
```

The expected SHA-256 is
`b0bc343f1af4ccb7270b7bd95ec3554e7a1f8d9e713850f6d871e0fa34752fc6`.
The helper includes only the nine `.patch` files, sorted by path, with fixed
tar/gzip metadata. It excludes READMEs and local ownership/timestamp metadata
and refuses to overwrite an existing destination. Use the per-file manifest
in [patches/README.md](patches/README.md) to verify the inputs independently.

## Local Checks Without Installation

Run each check from the tap root:

```sh
ruff --version
ruff check tools/
ruff format --check tools/
for formula in Formula/*.rb; do ruby -c "$formula"; done
git diff --check
brew style Formula
```

Use the Ruff executable on PATH consistently; older versions can check different
rules. The packaging helper has no third-party Python runtime dependencies.
Run `brew style` before copying formulas into a temporary tap or after removing
that copy: Homebrew can index both copies and report duplicate methods.
Homebrew may refresh its development gems on its first style/audit invocation.

An offline local-path `brew audit --strict` can supplement these checks when
supported by the installed Homebrew version. Do not treat a local audit as
verification of unpublished downloads or a complete installation. If Homebrew
requires tap registration or trust changes, perform those separately in an
explicitly isolated validation environment, not as part of a read-only check.

## Reproducing Source Builds

Download each literal formula URL into a separate build directory, verify its
SHA-256 against [PUBLISHING.md](PUBLISHING.md), and extract into a fresh source
tree. The patches URL is usable only after publication. Stage its contents as
`chatty-patches/` in each bridge source tree, and stage the whatsmeow resource as
`whatsmeow/` in the WhatsApp tree. Follow the formula's exact patch order and
`go mod edit -replace` command; do not edit a shared module cache.

Run the `install` method's commands with its exact environment and arguments,
substituting only an isolated staging destination for the Homebrew keg.
The Go formulas set `GOMAXPROCS=2`, `GOTOOLCHAIN=local`, `GOFLAGS=-mod=readonly`
and build with `-p 2 -trimpath`. Both bridges set `CGO_ENABLED=1`, use `goolm`
and set `SOURCE_DATE_EPOCH=1792163004`. Preserve their linker metadata:

```sh
go build -p 2 -trimpath -o chatty-bridges github.com/beeper/bridge-manager/cmd/chatty-bridges
go build -p 2 -trimpath -tags goolm -ldflags '-X main.Tag=v0.2610.0 -X main.Commit=1067291a89f4949887b328104005abe4f7163ddf -X main.BuildTime=2026-10-16T15:03:24Z' -o mautrix-whatsapp ./cmd/mautrix-whatsapp
go build -p 2 -trimpath -tags goolm -ldflags '-X main.Tag=v0.2610.0 -X main.Commit=3c16226686c71af64df294df0803791685064e0b -X main.BuildTime=2026-10-16T15:03:24Z' -o mautrix-instagram ./cmd/mautrix-instagram
```

These examples do not replace the preceding checks in the recipes. WhatsApp
runs full tests, race tests and vet for both patched whatsmeow and the bridge.
Instagram runs tests and vet for `./pkg/igconnector`, covering its patched
packages. Run these checks before compiling.

Tuwunel uses upstream Cargo.lock with `--locked`, default features,
`CARGO_BUILD_JOBS=2`, `HOMEBREW_MAKE_JOBS=2`, `CARGO_INCREMENTAL=0` and
`SOURCE_DATE_EPOCH=1791625810`. For an external native build, use:

```sh
nice -n 15 cargo build --locked --release -p tuwunel --bin tuwunel
```

The formula uses `cargo install *std_cargo_args(path: "src/main") --bin tuwunel`
to stage the same release/default-feature build. A prior local comparison on
`aarch64-apple-darwin` with Rust/Cargo 1.99.1 used the same source, environment
and target cache, then expanded the staging command as:

```sh
nice -n 15 cargo install --jobs 2 --locked --root="$E/tuwunel-keg" --path=src/main --bin tuwunel
```

Both executables had SHA-256
`b4d11ab541590917d061a43b45453299169b4daff2845da455af21060855b518`,
Cargo.lock stayed byte-identical to the upstream archive, and both version/help
checks passed. This is evidence of build/staging equivalence on that host,
not a portable expected binary hash or a complete Homebrew installation test.

Record commands, complete output, exit codes and executable hashes for any new
build, then run each binary's `--version` and `--help`. Upstream version banners
do not identify Chatty patches; use the patch manifest and source/binary hashes.
Compilation and CLI checks do not prove pairing, registration, a running server
or operation against a real backend. Use synthetic fixtures and isolated caches,
configuration and data, never a live session for build validation.

## References

The recipes follow Homebrew's [tap format](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
and [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook). Licensing and
corresponding-source requirements are documented in [PUBLISHING.md](PUBLISHING.md).
