<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/fiscusproject/brandbook/master/banner/fiscus-readme-tagline-1280x320-dark.png">
    <img src="https://raw.githubusercontent.com/fiscusproject/brandbook/master/banner/fiscus-readme-tagline-1280x320-light.png" alt="Fiscus — free and open-source fiscalization" width="640">
  </picture>
</p>

# website-infrastructure

Terraform for [fiscusproject.eu](https://fiscusproject.eu): static site on S3 + CloudFront
(ACM, HTTPS-only), Cloudflare DNS with a proxied `www` redirect, and an OIDC role that
lets the website repo's GitHub Actions deploy without stored AWS keys. Secrets live in
`secrets-website.yaml`, sops-encrypted with the KMS key managed here.

## Usage

### In a dev container

`.devcontainer/` defines a [Dev Pod](https://devpod.sh) that installs the
pinned toolchain automatically:

```sh
devpod up . --ide vscode
```

### On your machine

```sh
mise install
```

### Plan and apply

AWS credentials are required (in a dev container, provide them inside it — e.g. as
environment variables — since nothing from the host is mounted in):

```sh
terraform init
erraform workspace select website
terraform plan
terraform apply
```

State lives in the `fiscus-website-tfstate` S3 bucket. After an apply that changes
outputs, update the repository variables in the website repo's GitHub Actions settings
(`AWS_DEPLOY_ROLE_ARN`, `S3_BUCKET`, `CLOUDFRONT_DISTRIBUTION_ID`).

## License

Licensed under the [MIT License](LICENSE). The Fiscus name and logo are **not** covered;
their use is governed by the
[trademark policy](https://github.com/fiscusproject/brandbook/blob/master/TRADEMARK.md).

## AI Policy

On October 22, 2026, we decided to fully align with the NLnet Foundation's AI policy requirements. From this date forward, AI will not be used to produce or edit code in this
repository.

[NLNet Foundation AI Policy Version 2.0](https://nlnet.nl/foundation/policies/generativeAI/2.0/)

### AI Policy Disclaimer

The code in this repository prior to October 22 was already aligned with Version 2.0 of the NLnet Foundation's AI policy requirements.
