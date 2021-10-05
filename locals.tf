locals {
  assume_roles_flatten = flatten([
    for role_key, role in var.roles : [
      for assume_role in role.assume_roles : {
        index       = format("%s-%s", role.name, element(split("/", assume_role), 1))
        name        = role.name
        assume_role = assume_role
        conditions  = role.conditions
      }
    ]
  ])
  assume_policies_flatten = flatten([
    for role_key, role in var.roles : [
      for assume_policy in role.assume_policies : {
        index         = format("%s-%s", role.name, element(split("/", assume_policy), 1))
        role_name     = role.name
        assume_policy = assume_policy
      }
    ]
  ])
}