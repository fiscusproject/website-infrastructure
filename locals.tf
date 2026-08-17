locals {
  tags = {
    Terraform   = "true"
    Environment = "website"
  }
  cloudflare_secrets = nonsensitive(yamldecode(data.sops_file.secrets.raw).cloudflare)

  domain             = "fiscusproject.eu"
  cloudflare_zone_id = "ad7b8c3e57c3a27faf8a636ee6c18be8"
  site_bucket_name   = "fiscusproject-eu-website"
  github_repository  = "fiscusproject/website" # owner/repo allowed to deploy via OIDC
}
