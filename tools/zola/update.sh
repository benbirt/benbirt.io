#!/usr/bin/env bash
# Points MODULE.bazel at the latest Zola release: the version, and the sha256 of
# each platform's archive, taken from the release's asset digests.
#
# Needs gh (authenticated, or with GH_TOKEN set) and jq.
set -euo pipefail

cd "$(dirname "$0")/../.."

release="$(gh api repos/getzola/zola/releases/latest)"
version="$(jq -r '.tag_name | ltrimstr("v")' <<<"$release")"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "unexpected Zola version: $version" >&2
  exit 1
}

sed -i -E "s/^(ZOLA_VERSION = \")[^\"]*/\1${version}/" MODULE.bazel

# Every platform MODULE.bazel names: the second string of each ("name", "triple", "sha256").
triples="$(sed -n -E 's/^ *\("[a-z0-9_]+", "([a-z0-9_-]+)", "[0-9a-f]{64}"\),$/\1/p' MODULE.bazel)"
[[ -n "$triples" ]] || {
  echo "found no Zola platforms in MODULE.bazel" >&2
  exit 1
}

for triple in $triples; do
  asset="zola-v${version}-${triple}.tar.gz"
  sha256="$(jq -r --arg name "$asset" '.assets[] | select(.name == $name) | .digest | ltrimstr("sha256:")' <<<"$release")"
  [[ "$sha256" =~ ^[0-9a-f]{64}$ ]] || {
    echo "no sha256 digest for $asset" >&2
    exit 1
  }
  sed -i -E "s/(\"${triple}\", \")[0-9a-f]{64}/\1${sha256}/" MODULE.bazel
done

echo "$version"
