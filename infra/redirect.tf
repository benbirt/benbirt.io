# eavesbard.benbirt.io redirects every request to the same path on
# eavesbard.com, keeping the query string: a Single Redirect rule, in the
# zone's entry point ruleset for the dynamic redirect phase (Cloudflare names
# entry point rulesets "default"). Further redirects in the zone go in this
# ruleset too, as a zone has only one per phase.

# The name has to resolve, and be proxied, for Cloudflare to see the requests.
# The addresses are placeholders that nothing reaches (RFC 5737, RFC 6666).
resource "cloudflare_dns_record" "eavesbard_a" {
  zone_id = local.zone_id
  name    = "eavesbard.${local.domain}"
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = true
  comment = "Redirects to eavesbard.com (redirect.tf)"
}

resource "cloudflare_dns_record" "eavesbard_aaaa" {
  zone_id = local.zone_id
  name    = "eavesbard.${local.domain}"
  type    = "AAAA"
  content = "100::"
  ttl     = 1
  proxied = true
  comment = "Redirects to eavesbard.com (redirect.tf)"
}

resource "cloudflare_ruleset" "redirects" {
  zone_id = local.zone_id
  name    = "default"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules = [
    {
      ref         = "ca15ddefa2c3b0fab8401fcee843e615"
      description = "eavesbard.benbirt.io to eavesbard.com"
      expression  = "http.host eq \"eavesbard.${local.domain}\""
      action      = "redirect"
      enabled     = true
      action_parameters = {
        from_value = {
          status_code           = 301
          preserve_query_string = true
          target_url = {
            expression = "concat(\"https://eavesbard.com\", http.request.uri.path)"
          }
        }
      }
    },
  ]
}
