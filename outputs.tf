output "cloudfront_domain_name" {
  description = "CloudFront distribution hostname (Cloudflare CNAME target)"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "cloudfront_distribution_id" {
  description = "Set as CLOUDFRONT_DISTRIBUTION_ID repository variable in GitHub"
  value       = aws_cloudfront_distribution.website.id
}

output "site_bucket" {
  description = "Set as S3_BUCKET repository variable in GitHub"
  value       = aws_s3_bucket.website.bucket
}

output "deploy_role_arn" {
  description = "Set as AWS_DEPLOY_ROLE_ARN repository variable in GitHub"
  value       = aws_iam_role.website-deploy.arn
}
