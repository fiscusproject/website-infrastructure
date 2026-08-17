# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Terraform (single root module, no submodules) for the static site at fiscusproject.eu. Tool versions are pinned via [mise](https://mise.jdx.dev) in `mise.toml` (Terraform 1.15, sops 3.13). AWS credentials are required for nearly everything, including `terraform plan` — the sops provider decrypts `secrets-website.yaml` with a KMS key at plan time.

## Commands

```sh
terraform init       # backend: S3 bucket fiscus-website-tfstate (eu-north-1)
terraform plan
terraform apply
terraform fmt        # formatting
terraform validate

sops secrets-website.yaml   # edit encrypted secrets (needs KMS access)
```

There are no tests or linters beyond `fmt`/`validate`.

## Architecture

Request path: Cloudflare DNS (apex CNAME, DNS-only) → CloudFront → private S3 bucket via Origin Access Control. `www` is the only proxied Cloudflare record, and only so a Cloudflare ruleset can 301 it to the apex — no site traffic flows through Cloudflare.

Cross-file wiring that isn't obvious from any single file:

- **Two AWS providers** (`provider.tf`): default `eu-central-1`, plus an `aws.us_east_1` alias used by `acm.tf` — CloudFront only accepts ACM certificates issued in us-east-1.
- **Secrets bootstrap loop**: `kms.tf` manages the KMS key that sops uses (referenced by ARN in `.sops.yaml`), `data.tf` decrypts `secrets-website.yaml`, and `locals.tf` exposes the Cloudflare API token from it — which configures the Cloudflare provider itself.
- **GitHub OIDC deploy** (`github-oidc.tf`): the separate `website` repo deploys via `sts:AssumeRoleWithWebIdentity`, scoped to its master branch — no stored AWS keys. The subject claim in `locals.github_repository` uses the immutable format with numeric owner/repo IDs (`owner@id/repo@id`); do not "simplify" it back to plain `owner/repo`.
- **ACM validation records** in `acm.tf` are created in Cloudflare and must stay `proxied = false`, or validation never completes.
- **CloudFront function** in `cloudfront.tf` rewrites extensionless/trailing-slash URIs to `index.html` (S3 REST origins don't resolve directory indexes), and 403s from S3 are remapped to the Hugo `/404.html` page (with OAC, missing objects surface as 403, not 404).

## After applying

If an apply changes outputs, update the repository variables in the website repo's GitHub Actions settings: `AWS_DEPLOY_ROLE_ARN`, `S3_BUCKET`, `CLOUDFRONT_DISTRIBUTION_ID` (see `outputs.tf`).

## Conventions

- Provider versions in `init.tf` are pinned (Cloudflare exactly `5.1.0`); `.terraform.lock.hcl` is committed.
- Resources are tagged with `merge({ Name = ... }, local.tags)`.
- The repo is mirrored to Codeberg via `.github/workflows/mirror.yml` (reusable workflow in `fiscusproject/.github`); pushes trigger it automatically.
