resource "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.rg_name

  tenant_id = var.tenant_id

  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  tags = var.tags

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules = [
      "104.211.92.205/32",
      "49.36.190.70/32"
    ]
  }

  # GitHub Actions Terraform Service Principal
  access_policy {
    tenant_id = var.tenant_id
    object_id = "134042f2-ad57-44ff-8b89-3d28b6e232de"

    secret_permissions = [
      "Get",
      "Set",
      "Delete",
      "List",
    ]
  }

  # Current/local Azure user
  access_policy {
    tenant_id = var.tenant_id
    object_id = var.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
      "Set",
      "Delete",
      "List",
    ]

    storage_permissions = [
      "Get",
    ]
  }
  lifecycle {
    ignore_changes = [
      access_policy
    ]
  }
}
