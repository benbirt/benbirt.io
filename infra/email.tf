# ben@benbirt.io, forwarded by Cloudflare Email Routing. It only receives:
# sending from the address is a separate piece of work (issue #2).

locals {
  # The mailbox that ben@benbirt.io forwards to.
  forward_to = "benjamin.birt@gmail.com"
}

# Turns Email Routing on for the zone, which adds the MX, SPF and DKIM records
# it needs. Cloudflare owns those records, so they are not declared here.
resource "cloudflare_email_routing_dns" "this" {
  zone_id = local.zone_id
}

# Cloudflare emails the mailbox a link, and forwards nothing to it until the
# link has been followed.
resource "cloudflare_email_routing_address" "forward_to" {
  account_id = local.account_id
  email      = local.forward_to
}

resource "cloudflare_email_routing_rule" "ben" {
  zone_id = local.zone_id
  name    = "ben"
  enabled = true

  matchers = [{
    type  = "literal"
    field = "to"
    value = "ben@${local.domain}"
  }]

  actions = [{
    type  = "forward"
    value = [cloudflare_email_routing_address.forward_to.email]
  }]

  depends_on = [cloudflare_email_routing_dns.this]
}

# Nothing sends mail as benbirt.io yet, so receivers are told to reject
# anything that claims to. To be revisited with issue #2.
resource "cloudflare_dns_record" "dmarc" {
  zone_id = local.zone_id
  name    = "_dmarc.${local.domain}"
  type    = "TXT"
  content = "\"v=DMARC1; p=reject;\""
  ttl     = 1
  comment = "DMARC"
}
