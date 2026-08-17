locals {
  tags = {
    Terraform   = "true"
    Environment = "website"
  }
  cloudflare_secrets = nonsensitive(yamldecode(data.sops_file.secrets.raw).cloudflare)

  domain             = "fiscusproject.eu"
  cloudflare_zone_id = "ad7b8c3e57c3a27faf8a636ee6c18be8"
  site_bucket_name   = "fiscusproject-eu-website"
  # Repos created after 2026-07-15 emit immutable OIDC subject claims that embed
  # the numeric owner/repo IDs, so the trust policy must match this form:
  # https://github.blog/changelog/2026-04-23-immutable-subject-claims-for-github-actions-oidc-tokens/
  github_repository = "fiscusproject@316636023/website@1334388695" # owner/repo allowed to deploy via OIDC
}
