# benbirt.io's DNS records and email routing in Cloudflare, and the PostHog
# dashboard in posthog.tf, so that they are reviewed and changed here and not
# in Cloudflare's or PostHog's UI. CI plans on pull requests and applies on
# pushes to main (.github/workflows/infra.yml).
#
# Credentials come from the environment:
#   CLOUDFLARE_API_TOKEN                       the one Cloudflare token (README.md): the zone and the
#                                              state bucket
#   AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY   the state bucket's S3 keys, derived from that token
#                                              by tools/r2-keys.sh
#   POSTHOG_API_KEY                            personal API key for PostHog project 306168 (README.md)
# Locally (on termina, with the keys in KDE Wallet): infra/run.sh plan

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.29.0"
    }
    posthog = {
      source  = "PostHog/posthog"
      version = "1.0.32"
    }
  }

  # State in Cloudflare R2, through its S3-compatible API. R2 supports the
  # conditional writes use_lockfile needs; the skip_* settings turn off the
  # AWS-only checks.
  backend "s3" {
    bucket                      = "benbirt-io-tofu-state"
    key                         = "infra/terraform.tfstate"
    region                      = "auto"
    endpoints                   = { s3 = "https://5154cc96c06ec81c712d8fd51a642c9c.eu.r2.cloudflarestorage.com" }
    use_lockfile                = true
    use_path_style              = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}

provider "cloudflare" {}

locals {
  domain = "benbirt.io"
}

# The zone already exists: the domain is registered with Cloudflare.
data "cloudflare_zone" "this" {
  filter = {
    name = local.domain
  }
}

locals {
  zone_id    = data.cloudflare_zone.this.zone_id
  account_id = data.cloudflare_zone.this.account.id
}

resource "cloudflare_zone_dnssec" "this" {
  zone_id = local.zone_id
  status  = "active"
}
