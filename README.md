# terraform-aws-vcs-oidc

[![Lint Status](https://github.com/DNXLabs/terraform-aws-vcs-oidc/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-vcs-oidc/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-vcs-oidc)](https://github.com/DNXLabs/terraform-aws-vcs-oidc/blob/main/LICENSE)

This module sets up IAM Roles and Identity Provider for various VCS(Version Control Systems) providers.

Supported providers:
 - Bitbucket
 - GitHub

The following resources will be created:
 - IAM Role.
 - IAM Policy attachment.
 - IAM Identity Provider Web Identity.

## Usage

- [Bitbucket](examples/bitbucket.md)
- [GitHub](examples/github.md)


<!--- BEGIN_TF_DOCS --->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| audiences | Also known as client ID, audience is a value that identifies the application that is registered with an OpenID Connect provider. | `list(string)` | n/a | yes |
| identity\_provider\_url | Specify the secure OpenID Connect URL for authentication requests. | `string` | n/a | yes |
| oidc\_thumbprint | Thumbprint of OIDC host. See https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html | `string` | `""` | no |
| roles | List of roles to create. | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| identity\_provider\_arn | n/a |
| roles | n/a |

<!--- END_TF_DOCS --->

## Authors

Module managed by [DNX Solutions](https://github.com/DNXLabs).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/DNXLabs/terraform-aws-vcs-oidc/blob/main/LICENSE) for full details.
