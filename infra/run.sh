#!/usr/bin/env bash
# Plans or applies the domain's configuration from this computer, with the keys
# from KDE Wallet (stored with secret-tool; README.md lists them). CI normally
# applies it, on pushes to main; this is for trying a change first.
#   infra/run.sh plan|apply
set -o errexit -o nounset -o pipefail

secret() { nix shell nixpkgs#libsecret --command secret-tool lookup "$@"; }

CLOUDFLARE_API_TOKEN=$(secret service cloudflare zone benbirt.io)
AWS_ACCESS_KEY_ID=$(secret service r2 bucket benbirt-io-tofu-state field access-key-id)
AWS_SECRET_ACCESS_KEY=$(secret service r2 bucket benbirt-io-tofu-state field secret-access-key)
TF_VAR_forward_to=$(secret service cloudflare zone benbirt.io field forward-to)
export CLOUDFLARE_API_TOKEN AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY TF_VAR_forward_to

case "${1:-}" in
  plan | apply) exec bazel run "//infra:infra.$1" ;;
  *)
    echo "usage: $0 plan|apply" >&2
    exit 2
    ;;
esac
