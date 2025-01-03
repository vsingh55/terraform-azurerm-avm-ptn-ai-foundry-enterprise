data "azurerm_role_definition" "eligible_roles" {
  for_each           = var.eligible_roles
  role_definition_id = each.value
}


locals {
  user_role_assignments = flatten([
    for group, members in var.group_assignments : [
      for member in members : [
        for role in var.role_templates[group] : {
          group     = group
          type      = member.type
          object_id = member.objectid
          name      = member.name
          role_name = role.role_name
          role_id   = "/subscriptions/${var.subscription_id}${data.azurerm_role_definition.eligible_roles[role.role_name].id}"
          scope     = var.scopes[role.scope]
        }
      ]
    ]
  ])
}

resource "azurerm_role_assignment" "dynamic_user_role_assignments" {
  for_each           = { for role in local.user_role_assignments : "${role.group}-${role.role_name}-${role.object_id}" => role }
  scope              = each.value.scope
  role_definition_id = each.value.role_id
  principal_id       = each.value.object_id
}

locals {
  managed_identity_role_assignments_map = {
    for idx, role in var.managed_identity_roles : idx => {
      role_name = role.role_name
      role_id   = "/subscriptions/${var.subscription_id}${data.azurerm_role_definition.eligible_roles[role.role_name].id}"
      object_id = role.object_id
      scope     = var.scopes[role.scope]
    }
  }
}


resource "azurerm_role_assignment" "dynamic_managed_identity_role_assignments" {
  for_each = local.managed_identity_role_assignments_map

  role_definition_id = each.value.role_id
  scope              = each.value.scope
  principal_id       = each.value.object_id
}
