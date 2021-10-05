# Bitbucket

Use OpenID Connect (OIDC) to allow your pipelines to access your resource server, such as AWS, GCP, or Vault. Below is all the information required to setup an OIDC identity provider on your resource server. [Learn more](https://support.atlassian.com/bitbucket-cloud/docs/integrate-pipelines-with-resource-servers-using-oidc/)

In this step, you are going to configure your build to the assume the role created in the previous step. You need to enable your BitbucketCI step to create a unique OIDC token that can be used to assume a role and request a temporary credential. This token is exposed as an environment variable `BITBUCKET_STEP_OIDC_TOKEN`.

https://support.atlassian.com/bitbucket-cloud/docs/deploy-on-aws-using-bitbucket-pipelines-openid-connect

To find information about indentity provider URL and Audience go to `https://bitbucket.org/<WORKSPACE>/<REPO>/admin/addon/admin/pipelines/openid-connect`

#### Terraform setup

```bash
module "bitbucket_oidc" {
  source = "git::https://github.com/DNXLabs/terraform-aws-vcs-oidc.git"

  identity_provider_url = "https://api.bitbucket.org/2.0/workspaces/{WORKSPACE}/pipelines-config/identity/oidc"
  audiences              = [
    "ari:cloud:bitbucket::workspace/{WORKSPACE-UUID}"
  ]

  roles = [
    {
        name = "CIDeployBitbucket"
        assume_roles = [
          "arn:aws:iam::*:role/InfraDeployAccess" # Optional
        ]
        assume_policies = [
          "arn:aws:iam::aws:policy/AdministratorAccess" # Optional
        ]
        conditions = [
          {
            test     = "ForAnyValue:StringLike"
            variable = "api.bitbucket.org/2.0/workspaces/{WORKSPACE}/pipelines-config/identity/oidc:sub"
            # {REPOSITORY_UUID}*:{ENVIRONMENT_UUID}:* or {REPOSITORY_UUID}:*
            # Max of ~30 conditions.
            values   = "*:*"
          },
          { # Limit only assumes requests coming from Bitbucket Pipelines IP to assume the role.
            test     = "IpAddress"
            variable = "aws:SourceIp"
            values   = [
              "34.199.54.113/32",
              "34.232.25.90/32",
              "34.232.119.183/32",
              "34.236.25.177/32",
              "35.171.175.212/32",
              "52.54.90.98/32",
              "52.202.195.162/32",
              "52.203.14.55/32",
              "52.204.96.37/32",
              "34.218.156.209/32",
              "34.218.168.212/32",
              "52.41.219.63/32",
              "35.155.178.254/32",
              "35.160.177.10/32",
              "34.216.18.129/32"
            ]
          }
        ]
    }
  ]
}
```

#### Example of bitbucket-pipelines.yml file

```yml
image: amazon/aws-cli

pipelines:
  default:
    - step:
      oidc: true
      script:
        - export AWS_REGION=us-west-2
        - export AWS_ROLE_ARN=arn:aws:iam::<XXXXXXXXXXXX>:role/<BitbucketRole>
        - export AWS_WEB_IDENTITY_TOKEN_FILE=$(pwd)/web-identity-token
        - echo $BITBUCKET_STEP_OIDC_TOKEN > $(pwd)/web-identity-token
        - aws sts get-caller-identity
```

> The above code is an example of bitbucket-pipelines.yml file that assumes the role to request temporary credentials that can be used to access AWS resources.