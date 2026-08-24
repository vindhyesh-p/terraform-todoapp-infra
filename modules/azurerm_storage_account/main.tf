resource "azurerm_storage_account" "strg" {
  name                     = var.strg_name
  location                 = var.location
  resource_group_name      = var.rg_name
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  network_rules {
    default_action = "Deny"
  }

  tags = var.tags
}
