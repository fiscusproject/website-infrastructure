terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "1.0.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "= 5.1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket  = "fiscus-website-tfstate"
    region  = "eu-north-1"
    key     = "terraform.tfstate"
    encrypt = true
  }
  required_version = "~> 1.15.0"
}
