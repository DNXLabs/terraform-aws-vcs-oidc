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


<!--- END_TF_DOCS --->

## Authors

Module managed by [DNX Solutions](https://github.com/DNXLabs).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/DNXLabs/terraform-aws-vcs-oidc/blob/main/LICENSE) for full details.
