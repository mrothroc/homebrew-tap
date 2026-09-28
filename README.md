# mrothroc/homebrew-tap

Homebrew tap for [mixlab](https://github.com/mrothroc/mixlab).

## Install

```bash
brew install mrothroc/tap/mixlab
brew trust mrothroc/tap
```

The first command installs mixlab and MLX. On macOS 15 and 26 it pours a prebuilt
bottle; elsewhere, or when Homebrew's MLX is outside the range mixlab was tested
against, it builds from source. The second lets a plain `brew upgrade` include mixlab:
Homebrew 7 loads formulae from a tap you have not trusted only when a command names
them in full, so without it, upgrade with `brew upgrade mrothroc/tap/mixlab`.

## How releases arrive

This repository is the source of the formula, maintained with Homebrew's standard
tap workflows. A daily autobump opens a pull request when mixlab publishes a new
release. `brew test-bot` audits it, builds it from source, runs `brew test`, and builds
bottles on macOS 15 and 26; `brew pr-pull` then publishes it with those bottles. Pull
requests that change the formula go through the same checks.

Autobump opens its pull requests with the `HOMEBREW_BUMP_TOKEN` secret, a fine-grained
token limited to this repository's contents and pull requests; pull requests opened
with a workflow's default token would not trigger the tests. A weekly check reads the
token's expiry from GitHub and opens an issue with rotation steps once 30 days or fewer
remain, then closes it when it sees the replacement.
