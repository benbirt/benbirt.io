#!/usr/bin/env bash
# Plans or applies the domain's configuration from termina, with the
# Cloudflare token from KDE Wallet (stored with secret-tool; README.md says
# how). CI normally applies it, on pushes to main; this is for trying a change
# first.
#   infra/run.sh plan|apply
set -o errexit -o nounset -o pipefail

secret() { nix shell nixpkgs#libsecret --command secret-tool lookup "$@"; }

case "${1:-}" in
  plan | apply)
    CLOUDFLARE_API_TOKEN=$(secret service cloudflare token benbirt-io-tofu)
    export CLOUDFLARE_API_TOKEN
    keys=$("$(dirname "$0")/../tools/r2-keys.sh")
    while IFS='=' read -r name value; do export "$name=$value"; done <<<"$keys"
    exec bazel run "//infra:infra.$1"
    ;;
  *)
    echo "usage: $0 plan|apply" >&2
    exit 2
    ;;
esac
