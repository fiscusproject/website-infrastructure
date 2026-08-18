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

The toolchain is pinned with [mise](https://mise.jdx.dev). Get it either way:

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

The code in this repository was produced with AI assistance. All decisions were made by the project maintainers, every line of code was human-reviewed, and the maintainers remain accountable for the accuracy and originality of the work.
