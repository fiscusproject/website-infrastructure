resource "aws_kms_key" "sops-file-key" {
  description              = "Symmetric KMS key used to encrypt/decrypt the secrets file with sops."
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 10
  enable_key_rotation      = false
  multi_region             = false
  tags = merge(
    { Name = "sops-file-key" },
    local.tags
  )
}

resource "aws_kms_alias" "sops-file-key-alias" {
  name          = "alias/sops-website-file-key"
  target_key_id = aws_kms_key.sops-file-key.key_id
}
