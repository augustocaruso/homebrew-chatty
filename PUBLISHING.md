# Publishing the Chatty Tap

## Publication Status

The `chatty-bridges` source is already public in
[`augustocaruso/bridge-manager`](https://github.com/augustocaruso/bridge-manager),
tag `chatty-2026.11.16`, commit
`685172c3a8de35b86d29bac58d357032acaf7937`. Its release asset has been downloaded
back and hash-checked, and its `cmd/chatty-bridges` build reports
`chatty-bridges version 0.1.0`. Per-machine settings are supplied through flags
or `~/Library/Application Support/Chatty/machine.json`, not embedded local defaults.

**Still pending:** create `augustocaruso/homebrew-chatty`, publish the contents
of this directory at its root, and create release `patches-2026.11.14` with asset
`chatty-patches-2026.11.14.tar.gz`. Publish `Formula/`, `patches/`, `tools/` and
these documents without the `Packaging/homebrew-chatty/` prefix.

The only pending release-asset URL in the formulas is:

```text
https://github.com/augustocaruso/homebrew-chatty/releases/download/patches-2026.11.14/chatty-patches-2026.11.14.tar.gz
```

Both `resource "chatty-patches"` blocks must retain the same URL and hash.
Do not advertise installation as available until the tap and all its literal
source URLs are public and verified. Local build/audit results do not prove
that a future URL resolves or that a full Homebrew installation succeeds.

## Source Pins

| Formula or resource | Public repository | Tag or revision | Commit |
| --- | --- | --- | --- |
| `tuwunel` | `matrix-construct/tuwunel` | `v1.9.4` | `f473d9a4a8342514302884041e0ccfea1ad503fc` |
| `chatty-mautrix-whatsapp` | `mautrix/whatsapp` | `v0.2610.0` | `1067291a89f4949887b328104005abe4f7163ddf` |
| `chatty-mautrix-instagram` | `mautrix/meta` | `v0.2610.0` | `3c16226686c71af64df294df0803791685064e0b` |
| `whatsmeow` | `tulir/whatsmeow` | `0b0a1cdac3e2a20d1436127d860bfe0c2b8ac9de` | `0b0a1cdac3e2a20d1436127d860bfe0c2b8ac9de` |
| `chatty-bridges` | `augustocaruso/bridge-manager` | `chatty-2026.11.16` | `685172c3a8de35b86d29bac58d357032acaf7937` |

Tuwunel needs no fork or patches and uses the upstream Cargo.lock with
`--locked`. WhatsApp and Instagram use Chatty's server patches; see
[patches/README.md](patches/README.md) for their bases, exact order and individual
hashes. The whatsmeow resource is a public upstream snapshot patched locally
during the formula build.

## Source Archive Hashes

| Archive | SHA-256 |
| --- | --- |
| Tuwunel `v1.9.4.tar.gz` | `44c0efde8d5a540a7e670fbc60975499273c6b9c14b45d96cf4789864cfc7554` |
| WhatsApp `v0.2610.0.tar.gz` | `c52a10be169e604626305077fd47b6de2e95612f4935c890e7b0752ee278b5a9` |
| Meta `v0.2610.0.tar.gz` | `6fbf706e65c35ea455a01736670feca52a548ec102cbd3949f536fa3d2c29ae2` |
| whatsmeow `0b0a1cdac3e2a20d1436127d860bfe0c2b8ac9de.tar.gz` | `5f681469fd00acbe002d60aba5e7b8ab5bcdca742720f08e8dbbb61fb1668753` |
| `chatty-patches-2026.11.14.tar.gz` | `b0bc343f1af4ccb7270b7bd95ec3554e7a1f8d9e713850f6d871e0fa34752fc6` |
| `chatty-bridges-2026.11.16.tar.gz` | `329849d3f57bf8a8e3116204bb4090a1806917b49012b495e2607392e2ed4832` |

The published CLI asset URL is:

```text
https://github.com/augustocaruso/bridge-manager/releases/download/chatty-2026.11.16/chatty-bridges-2026.11.16.tar.gz
```

Use this release asset, not GitHub's automatically generated tag archive.
The source pins and hashes identify the actual archives used by the recipes.

## Reproduce the Patches Release

From the tap root, choose a new destination in a separate build directory:

```sh
export E="$(mktemp -d)"
uv run --no-project python tools/package_patches.py "$E/chatty-patches-2026.11.14.tar.gz"
shasum -a 256 "$E/chatty-patches-2026.11.14.tar.gz"
```

The helper uses only the Python standard library. It sorts the nine `.patch`
paths, uses USTAR format, sets file permissions to `0644`, timestamps and numeric
ownership to zero, leaves owner names and the gzip filename empty, and excludes
README files. It refuses to overwrite an existing file. The result must match
`b0bc343f1af4ccb7270b7bd95ec3554e7a1f8d9e713850f6d871e0fa34752fc6`.
Stop and investigate any mismatch; do not update hashes simply to make a check pass.
Python is not required to install the formulas.

Upload these exact bytes as the release asset, not a GitHub-generated source
archive. Verify each downloaded or regenerated archive with:

```sh
shasum -a 256 "$E/<archive>.tar.gz"
```

After publication, download **every literal URL from the formulas**, including
resources, into new files:

```sh
curl --fail --location '<literal-formula-URL>' -o "$E/<new-archive>.tar.gz"
shasum -a 256 "$E/<new-archive>.tar.gz"
```

Compare hashes, archive contents and pinned revisions. A 404, invalid redirect
or hash mismatch is a failure. Investigate changed bytes, review any required
formula change, and repeat the affected checks. Never overwrite a released
asset with different bytes under the same version.

## Build and Installation Validation

Follow [README.md](README.md) for source build commands and environments,
including `SOURCE_DATE_EPOCH=1791625810` for Tuwunel and
`SOURCE_DATE_EPOCH=1792163004` for both bridges. Preserve linker metadata, patch
order, upstream lockfiles, Go read-only module resolution, CGO and `goolm` flags.

After the remaining publication steps, verify download readback and provenance,
repeat style/audit, and test installation in an isolated environment. Exercise
the formula tests and verify that installation creates no configuration or
database and starts no service. Source builds outside Homebrew are useful
checks but do not replace an installation test. Keep existing sessions and
backends untouched; pairing, appservice registration, adoption, upgrades and
restarts are separate explicit operations.

## Licensing and Distribution

Licenses recorded from the source snapshots:

- **Tuwunel: Apache-2.0**, from `Cargo.toml` and `LICENSE` in `v1.9.4`.
- **mautrix WhatsApp and Meta: AGPL-3.0-or-later**, from the version 3 `LICENSE` and source headers permitting later versions in both tags.
- **bridge-manager: Apache-2.0**, from the CLI source's `LICENSE`.
- **whatsmeow: MPL-2.0**, from the pinned revision's `LICENSE`; preserve notices and make modified files available alongside the combined distribution's obligations.

Modified bridges must preserve notices, identify modifications and offer the
Corresponding Source for the version actually distributed, including the
instructions and materials needed to rebuild it. AGPL section 13 also requires
a prominent offer of free access to corresponding source for users interacting
remotely with the modified version. An upstream-only link does not cover
Chatty's patches or modified whatsmeow.

Keep the bases, applicable patches and reproducible recipes/instructions
accessible together. Future binary or bottle distribution must also meet AGPL
section 6. The distributor/operator is responsible for the source offer on a
running bridge; these formulas neither configure nor verify that offer in a
live session. Preserve applicable `LICENSE` and `NOTICE` files in source and
future Apache-2.0 distributions. Do not remove upstream attribution.
