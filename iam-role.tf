resource "aws_iam_role" "default" {
  for_each           = { for role in var.roles : role.name => role }
  name               = each.value.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_saml[each.key].json
}

resource "aws_iam_role_policy_attachment" "default" {
  for_each   = { for role in local.assume_policies_flatten : role.index => role }
  role       = each.value.role_name
  policy_arn = data.aws_iam_policy.default[each.key].arn

  depends_on = [aws_iam_role.default]
}

data "aws_iam_policy" "default" {
  for_each = { for role in local.assume_policies_flatten : role.index => role }
  arn      = each.value.assume_policy
}

data "aws_iam_policy_document" "assume_role_saml" {
  for_each = { for role in var.roles : role.name => role }

  statement {
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.identity_provider_url, "https://", "")}"
      ]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]

    dynamic "condition" {
      for_each = each.value.conditions
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

resource "aws_iam_role_policy" "assume_role" {
  for_each    = { for role in local.assume_roles_flatten : role.index => role }
  name_prefix = "${each.value.name}-${element(split("/", each.value.assume_role), 1)}"
  role        = each.value.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = each.value.assume_role
      },
    ]
  })

  depends_on = [aws_iam_role.default]
}

resource "aws_iam_openid_connect_provider" "default" {
  url = var.identity_provider_url

  client_id_list = var.audiences

  thumbprint_list = compact([
    var.oidc_thumbprint != "" ? var.oidc_thumbprint : "",
    data.tls_certificate.thumprint.certificates.0.sha1_fingerprint
  ])
}