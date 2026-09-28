# mrothroc/homebrew-tap

Homebrew tap for [mixlab](https://github.com/mrothroc/mixlab).

## Install

```bash
brew install mrothroc/tap/mixlab
brew trust mrothroc/tap
```

The first command builds mixlab from source on macOS and installs MLX as a
dependency. The second lets a plain `brew upgrade` include mixlab: Homebrew 7 loads
formulae from a tap you have not trusted only when a command names them in full, so
without it, upgrade with `brew upgrade mrothroc/tap/mixlab`.

## Do not edit here

`Formula/mixlab.rb` is rendered from
[`packaging/homebrew/mixlab.rb`](https://github.com/mrothroc/mixlab/blob/main/packaging/homebrew/mixlab.rb)
and pushed by that repository's publish workflow when a release is published, after
`brew audit --strict`, a from-source install and `brew test` pass. Changes made
directly in this repository are overwritten by the next release, so open issues and
pull requests against [mrothroc/mixlab](https://github.com/mrothroc/mixlab) instead.
