data "aws_caller_identity" "current" {}

data "tls_certificate" "thumprint" {
  url = var.identity_provider_url
}