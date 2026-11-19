# The site is served by GitHub Pages:
# https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site
#
# The records are not proxied through Cloudflare: GitHub issues the site's
# certificate itself, and has to see the domain pointing straight at it.

locals {
  github_pages_ipv4 = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
  github_pages_ipv6 = [
    "2606:50c0:8000::153",
    "2606:50c0:8001::153",
    "2606:50c0:8002::153",
    "2606:50c0:8003::153",
  ]
}

resource "cloudflare_dns_record" "apex_a" {
  for_each = toset(local.github_pages_ipv4)

  zone_id = local.zone_id
  name    = local.domain
  type    = "A"
  content = each.value
  ttl     = 1 # automatic
  proxied = false
  comment = "GitHub Pages"
}

resource "cloudflare_dns_record" "apex_aaaa" {
  for_each = toset(local.github_pages_ipv6)

  zone_id = local.zone_id
  name    = local.domain
  type    = "AAAA"
  content = each.value
  ttl     = 1
  proxied = false
  comment = "GitHub Pages"
}

# GitHub redirects www.benbirt.io to benbirt.io.
resource "cloudflare_dns_record" "www" {
  zone_id = local.zone_id
  name    = "www.${local.domain}"
  type    = "CNAME"
  content = "benbirt.github.io"
  ttl     = 1
  proxied = false
  comment = "GitHub Pages"
}

# Proves to GitHub that the benbirt account owns the domain, so that no other
# account can serve a site from it. The code is not a secret; it comes from
# GitHub: Settings, Pages, Add a domain.
resource "cloudflare_dns_record" "github_pages_challenge" {
  zone_id = local.zone_id
  name    = "_github-pages-challenge-benbirt.${local.domain}"
  type    = "TXT"
  content = "\"74fcaf82a393ddcb71e4574921ac88\""
  ttl     = 1
  comment = "GitHub Pages domain verification"
}

# The Flip 7 scorecard, served by GitHub Pages from benbirt/flip7-scorecard,
# whose Pages settings name this domain.
resource "cloudflare_dns_record" "flip7" {
  zone_id = local.zone_id
  name    = "flip7.${local.domain}"
  type    = "CNAME"
  content = "benbirt.github.io"
  ttl     = 1
  proxied = false
  comment = "GitHub Pages: benbirt/flip7-scorecard"
}
