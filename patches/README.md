# Patch Provenance and Application Order

These are Chatty's server patches for mautrix WhatsApp, its whatsmeow dependency
and the mautrix Instagram entrypoint. The public copies preserve the production
changes; one test fixture uses synthetic data as described below. The formulas
apply these files to the public upstream source snapshots, not to a separate
pre-patched source tree.

## Upstream Bases

| Component | Upstream base | Commit |
| --- | --- | --- |
| WhatsApp | `mautrix/whatsapp` `v0.2610.0` | `1067291a89f4949887b328104005abe4f7163ddf` |
| whatsmeow, WhatsApp dependency | `tulir/whatsmeow`, revision used by the bridge | `0b0a1cdac3e2a20d1436127d860bfe0c2b8ac9de` |
| Instagram | `mautrix/meta` `v0.2610.0` | `3c16226686c71af64df294df0803791685064e0b` |

## Application Order

First, in a fresh whatsmeow source tree, apply
`mautrix-whatsapp/whatsmeow/favorite-sticker-events.patch`. From the WhatsApp
bridge source tree, use
`go mod edit -replace=go.mau.fi/whatsmeow=<patched-copy>` to point only that
build to the patched dependency, without changing the shared module cache or
updating the dependency version.

Then apply the WhatsApp bridge patches in lexical order, as in the formula:

1. `mautrix-whatsapp/create-dm-history.patch`
2. `mautrix-whatsapp/favorite-stickers.patch`
3. `mautrix-whatsapp/recycle-media-request.patch`
4. `mautrix-whatsapp/viewing-presence.patch`

Instagram requires this explicit, non-lexical order:

1. `mautrix-meta/thread-backfill-pagination.patch`
2. `mautrix-meta/backfill-since.patch`
3. `mautrix-meta/portal-creation-window.patch`
4. `mautrix-meta/ghost-profile-name-stability.patch`

Both formulas use `git apply`, not `git am`. Instagram builds
`./cmd/mautrix-instagram`, never the Messenger entrypoint. Follow the formula's
test/vet commands after applying patches and before compiling; successful
copying alone does not prove applicability or correctness.

## Public Test Fixtures

The public patch set was checked for credentials, keys, tokens, personal
identifiers, phone numbers and host names before publication preparation.
Explicitly synthetic test credentials are not production credentials.

Only `mautrix-whatsapp/recycle-media-request.patch` needed fixture substitutions,
in the section adding `pkg/msgconv/from_matrix_chatty_test.go`, hunk
`@@ -0,0 +1,49 @@`. Eight `input`/`expected` lines across the four cases in
`TestStripLeadingWhatsAppGhostMention` use a synthetic phone number,
`@alice:example.org`, the server `example.org` and neutral text.

No function, condition, assertion, case name, line count or production section
changed. Production sections of all nine patches were compared byte-for-byte
with Chatty's server patch sources; the other eight files are unchanged copies.
The original personal fixture values are not included. Full patch application
and tests of the affected packages remain necessary for each new source base.

## SHA-256 Manifest

Paths are relative to this directory.

| File | SHA-256 |
| --- | --- |
| `mautrix-whatsapp/whatsmeow/favorite-sticker-events.patch` | `e6aef20fccf5d470b99444788b2d43b48320b3810132881d48589ee5d7f0be86` |
| `mautrix-whatsapp/create-dm-history.patch` | `f7ca3a6037fe5f8d50eb79746aac07e226f5871fc29879192db4f72eda6271c5` |
| `mautrix-whatsapp/favorite-stickers.patch` | `da4b0aa909f46339503ef1791992985c37848257ba50b8bda9cebeda4f94ddcd` |
| `mautrix-whatsapp/recycle-media-request.patch` | `faf2d3e2ba4ccb4b955e73805fb434a454081cacab16062697aa16d419233b6a` |
| `mautrix-whatsapp/viewing-presence.patch` | `430b63cba68bc16e3c6cbfba23d6da8a4d299c47462a133aad517bef2718dbfd` |
| `mautrix-meta/thread-backfill-pagination.patch` | `1f752c8fc32b9d48112909e7626f4b569a97da766a87103fbdb843a9e25f4325` |
| `mautrix-meta/backfill-since.patch` | `59f7fdde1ad1b4a0b8a283bed14af392732762316ca2cccf254c6accc422a3c7` |
| `mautrix-meta/portal-creation-window.patch` | `9febabaf40df2179f550f52ad136c2336e5b5538d461621472ca09c331a449a5` |
| `mautrix-meta/ghost-profile-name-stability.patch` | `259b99e5801e47d16b94ecaafdc367165d8166d898a15af598d2255fe11eb7fe` |

From the tap root, verify each input with
`shasum -a 256 patches/<path-from-table>` and compare it with this manifest.
Reproduce the deterministic nine-file release asset with
`tools/package_patches.py` as described in [PUBLISHING.md](../PUBLISHING.md).
Its SHA-256 is
`b0bc343f1af4ccb7270b7bd95ec3554e7a1f8d9e713850f6d871e0fa34752fc6`.
README changes do not change that asset because the helper packages only patches.

## Licenses

The bridge patches accompany mautrix AGPL-3.0-or-later code; the whatsmeow patch
accompanies MPL-2.0 code. Preserve upstream notices, provide modifications and
meet the source obligations described in [PUBLISHING.md](../PUBLISHING.md).
This tap does not relicense upstream code.
