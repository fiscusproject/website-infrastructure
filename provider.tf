provider "cloudflare" {
  api_token = local.cloudflare_secrets.api_token
}

provider "aws" {
  region = "eu-central-1"
}

# CloudFront only accepts ACM certificates issued in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
