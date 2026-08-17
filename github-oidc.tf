# Lets GitHub Actions assume an AWS role via OIDC — no long-lived keys in GitHub
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = local.tags
}

data "aws_iam_policy_document" "github-assume-role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only workflow runs from the master branch of the website repo
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_repository}:ref:refs/heads/master"]
    }
  }
}

data "aws_iam_policy_document" "website-deploy" {
  statement {
    sid       = "SyncSite"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.website.arn]
  }

  statement {
    sid = "WriteObjects"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.website.arn}/*"]
  }

  statement {
    sid       = "InvalidateCache"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [aws_cloudfront_distribution.website.arn]
  }
}

resource "aws_iam_role" "website-deploy" {
  name               = "fiscus-website-deploy"
  assume_role_policy = data.aws_iam_policy_document.github-assume-role.json

  tags = local.tags
}

resource "aws_iam_role_policy" "website-deploy" {
  name   = "website-deploy"
  role   = aws_iam_role.website-deploy.id
  policy = data.aws_iam_policy_document.website-deploy.json
}
