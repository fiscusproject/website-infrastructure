resource "cloudflare_dns_record" "fiscus-project-eu" {
  zone_id = local.cloudflare_zone_id
  name    = local.domain
  content = aws_cloudfront_distribution.website.domain_name
  type    = "CNAME"
  ttl     = 1 # auto
  proxied = false # DNS-only: visitors connect straight to CloudFront
}

# www stays proxied only so Cloudflare can serve the redirect rule below —
# no site traffic flows through Cloudflare, just the one-request 301 bounce
resource "cloudflare_dns_record" "www" {
  zone_id = local.cloudflare_zone_id
  name    = "www.${local.domain}"
  content = local.domain
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_ruleset" "www-redirect" {
  zone_id = local.cloudflare_zone_id
  name    = "Redirects"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules = [{
    description = "www to apex"
    expression  = "(http.host eq \"www.${local.domain}\")"
    action      = "redirect"
    action_parameters = {
      from_value = {
        status_code = 301
        target_url = {
          expression = "concat(\"https://${local.domain}\", http.request.uri.path)"
        }
        preserve_query_string = true
      }
    }
  }]
}
