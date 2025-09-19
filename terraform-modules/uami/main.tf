locals {
  normalized_role_assignments = [
    for idx, assignment in var.role_assignments :
    merge(assignment, {
      key = format("%s-%02d", var.name, idx)
    })
  ]
}

resource "azurerm_user_assigned_identity" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "this" {
  for_each = { for assignment in local.normalized_role_assignments : assignment.key => assignment }

  scope                = each.value.scope
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  role_definition_name = try(each.value.role_definition_name, null)
  role_definition_id   = try(each.value.role_definition_id, null)
}
