#!/usr/bin/env bash
# Points MODULE.bazel at the latest Zola release: the version, and the sha256 of
# each platform's archive, taken from the release's asset digests.
#
# Needs gh (authenticated, or with GH_TOKEN set) and jq.
set -euo pipefail

cd "$(dirname "$0")/../.."

fail() {
  echo "$1" >&2
  exit 1
}

release="$(gh api repos/getzola/zola/releases/latest)"
version="$(jq -r '.tag_name | ltrimstr("v")' <<<"$release")"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "unexpected Zola version: $version"

# Every platform MODULE.bazel names: the second string of each ("name", "triple", "sha256").
triples="$(sed -n -E 's/^ *\("[a-z0-9_]+", "([a-z0-9_-]+)", "[0-9a-f]{64}"\),$/\1/p' MODULE.bazel)"
[[ -n "$triples" ]] || fail "found no Zola platforms in MODULE.bazel"

# Each http_archive must be one of those platforms, or its sha256 would be left behind.
[[ "$(grep -c '[0-9a-f]\{64\}' MODULE.bazel)" == "$(wc -l <<<"$triples" | tr -d ' ')" ]] ||
  fail "MODULE.bazel has a sha256 that is not on a platform line"

# Work out every edit before making any, so that a failure leaves the file alone.
edits=(-e "s/^(ZOLA_VERSION = \")[^\"]*/\1${version}/")
for triple in $triples; do
  asset="zola-v${version}-${triple}.tar.gz"
  sha256="$(jq -r --arg name "$asset" '.assets[] | select(.name == $name) | (.digest // "") | ltrimstr("sha256:")' <<<"$release")"
  [[ "$sha256" =~ ^[0-9a-f]{64}$ ]] || fail "no sha256 digest for $asset"
  edits+=(-e "s/(\"${triple}\", \")[0-9a-f]{64}/\1${sha256}/")
done

# -i with a suffix, then removing the backup, works with both GNU and BSD sed.
sed -E -i.bak "${edits[@]}" MODULE.bazel
rm MODULE.bazel.bak
grep -q "^ZOLA_VERSION = \"${version}\"$" MODULE.bazel || fail "could not set ZOLA_VERSION in MODULE.bazel"

echo "$version"
