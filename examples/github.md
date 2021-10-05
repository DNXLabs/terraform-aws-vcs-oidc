# GitHub

GitHub Actions has the functionality that can vendor OpenID Connect credentials to jobs running on the platform. This is very exciting for AWS account administrators as it means that CI/CD jobs no longer need any long-term secrets to be stored in GitHub. But enough of that, here’s how it works:

First, an AWS IAM OIDC identity provider and an AWS IAM role that GitHub Actions can assume. You can do that by deploying this terraform module template to your account.

#### Terraform setup

```bash
module "github_oidc" {
  source = "git::https://github.com/DNXLabs/terraform-aws-vcs-oidc.git"

  identity_provider_url = "https://vstoken.actions.githubusercontent.com"
  audiences             = [
    "https://github.com/<owner>/<repo>"
  ]

  roles = [
    {
        name = "InfraDeployGithub"
        assume_roles = [
          "arn:aws:iam::*:role/InfraDeployAccess" # Optional
        ]
        assume_policies = [
          "arn:aws:iam::aws:policy/AdministratorAccess" # Optional
        ]
        conditions = [
          {
            test     = "ForAnyValue:StringLike"
            variable = "vstoken.actions.githubusercontent.com:sub"
            values   = "repo:<owner>/<repo>:*" # Max of ~30 conditions.
          }
        ]
    }
  ]
}
```

Next, the GitHub workflow definition. Put this in a repo:

#### Example of workflow yml file

Parameters to change:
- `Account id` inside `AWS_ROLE_ARN` variable.
- `Role name` inside `AWS_ROLE_ARN` variable.

```yml
name: OIDC
on:
  push:
    branches:
      - master
jobs:
  deploy:
    name: OIDC
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
    - run: sleep 5
    - name: Checkout
      uses: actions/checkout@v2
    - name: Configure AWS
      run: |
        export AWS_ROLE_ARN=arn:aws:iam::<XXXXXXXXX>:role/<GithubRole>
        export AWS_WEB_IDENTITY_TOKEN_FILE=/tmp/awscreds
        export AWS_DEFAULT_REGION=us-west-2

        echo AWS_WEB_IDENTITY_TOKEN_FILE=$AWS_WEB_IDENTITY_TOKEN_FILE >> $GITHUB_ENV
        echo AWS_ROLE_ARN=$AWS_ROLE_ARN >> $GITHUB_ENV
        echo AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION >> $GITHUB_ENV

        curl -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL" | jq -r '.value' > $AWS_WEB_IDENTITY_TOKEN_FILE
    - name: get-caller-identity
      run: |
        aws sts get-caller-identity
```

You now have a GitHub Actions workflow that assumes your role. It works because the AWS SDKs (and AWS CLI) support using the `AWS_WEB_IDENTITY_TOKEN_FILE` and `AWS_ROLE_ARN` environment variables since AWS EKS needed this.

### Some potential trust policies

Maybe you want an IAM role that can be assumed by any branch in any repo in your GitHub org, e.g. with relatively few permissions needed for PRs. You can do this:

```
conditions = [
  {
    test     = "ForAnyValue:StringLike"
    variable = "vstoken.actions.githubusercontent.com:sub"
    values   = "repo:<your-github-org>/*"
]
```

Maybe you want an IAM role scoped only to workflows on the main branches, because this will be doing sensitive deployments. In that case, you can do:

```
conditions = [
  {
    test     = "ForAnyValue:StringLike"
    variable = "vstoken.actions.githubusercontent.com:sub"
    values   = "repo:<your-github-org>/*:ref:refs/heads/main"
  }
]
```

Take a look at [glassechidna/ghaoidc](https://github.com/glassechidna/ghaoidc) in case you want to implement JWT claims as role session tags to your action.