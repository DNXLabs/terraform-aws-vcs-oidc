variable "identity_provider_url" {
  type        = string
  description = "Specify the secure OpenID Connect URL for authentication requests."
}

variable "audiences" {
  type        = list(string)
  description = "Also known as client ID, audience is a value that identifies the application that is registered with an OpenID Connect provider."
}

variable "roles" {
  type        = list(any)
  default     = []
  description = "List of roles to create."
}

variable "oidc_thumbprint" {
  type        = string
  default     = ""
  description = "Thumbprint of OIDC host. See https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html"
}