#!/usr/bin/env bash
# Points MODULE.bazel at the latest release of posthog-js on npm: the version,
# and the archive's integrity as the registry gives it.
#
# Needs curl and jq.
set -euo pipefail

cd "$(dirname "$0")/../.."

fail() {
  echo "$1" >&2
  exit 1
}

release="$(curl -fsS https://registry.npmjs.org/posthog-js/latest)"
version="$(jq -r '.version' <<<"$release")"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "unexpected posthog-js version: $version"
integrity="$(jq -r '.dist.integrity' <<<"$release")"
[[ "$integrity" =~ ^sha512-[A-Za-z0-9+/]{86}==$ ]] || fail "unexpected integrity for posthog-js $version: $integrity"

# This must be the only sha512 integrity in MODULE.bazel, or sed would change another.
[[ "$(grep -c 'integrity = "sha512-' MODULE.bazel)" == 1 ]] || fail "expected one sha512 integrity in MODULE.bazel"

# -i with a suffix, then removing the backup, works with both GNU and BSD sed.
sed -E -i.bak \
  -e "s/^(POSTHOG_JS_VERSION = \")[^\"]*/\1${version}/" \
  -e "s|^( *integrity = \")sha512-[^\"]*|\1${integrity}|" \
  MODULE.bazel
rm MODULE.bazel.bak
grep -q "^POSTHOG_JS_VERSION = \"${version}\"$" MODULE.bazel || fail "could not set POSTHOG_JS_VERSION in MODULE.bazel"
grep -qF "integrity = \"${integrity}\"" MODULE.bazel || fail "could not set the integrity in MODULE.bazel"

echo "$version"
