locals {
  common_tags = {
    "Managed_By"  = "Terraform"
    "Environment" = "prod"
    "Owner"       = "TodoApp Team"
  }
}

module "rg" {
  source   = "../../modules/azurerm_resource_group"
  rg_name  = "rg-prod-todoapp-01"
  location = "centralindia"
  tags     = local.common_tags
}

module "vnet" {
  source = "../../modules/azurerm_virtual_network"

  vnet_name     = "vnet-prod-todoapp-01"
  location      = "centralindia"
  rg_name       = module.rg.rg_name
  address_space = ["10.0.0.0/16"]

  tags = local.common_tags
}


module "aks_subnet" {
  source = "../../modules/azurerm_subnet"

  subnet_name      = "snet-aks"
  rg_name          = module.rg.rg_name
  vnet_name        = module.vnet.vnet_name
  address_prefixes = ["10.0.1.0/24"]
}

module "strg" {
  depends_on               = [module.rg]
  source                   = "../../modules/azurerm_storage_account"
  strg_name                = "strgprodtodoapp01"
  location                 = "centralindia"
  rg_name                  = "rg-prod-todoapp-01"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.common_tags
}

module "sql_server" {
  depends_on                   = [module.rg]
  source                       = "../../modules/azurerm_sql_server"
  sql_server_name              = "sql-prod-todoapp-01"
  rg_name                      = "rg-prod-todoapp-01"
  location                     = "centralindia"
  administrator_login          = "vkpadmin"
  administrator_login_password = "Vkp@123456789"
  tags                         = local.common_tags
}

module "sql_db" {
  depends_on  = [module.rg, module.sql_server]
  source      = "../../modules/azurerm_sql_database"
  sql_db_name = "sqldb-prod-todoapp"
  server_id   = module.sql_server.server_id
  max_size_gb = "2"
  tags        = local.common_tags
}


data "azurerm_client_config" "current" {}

module "keyvault" {
  source = "../../modules/azurerm_key_vault"

  key_vault_name = "kv-prod-todoapp-01"
  location       = "centralindia"
  rg_name        = module.rg.rg_name
  tenant_id      = data.azurerm_client_config.current.tenant_id
  object_id      = data.azurerm_client_config.current.object_id
  tags           = local.common_tags
}


module "sql_password_secret" {
  depends_on   = [module.keyvault, module.sql_server]
  source       = "../../modules/azurerm_key_vault_secret"
  secret_name  = "sql-admin-password"
  secret_value = var.sql_admin_password
  key_vault_id = module.keyvault.key_vault_id
}


module "pip" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_public_ip"
  pip_name   = "pip-prod-todoapp"
  rg_name    = "rg-prod-todoapp-01"
  location   = "centralindia"
  sku        = "Standard"
  tags       = local.common_tags
}

module "acr" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_container_registry"
  acr_name   = "acrprodtodoapp01"
  rg_name    = "rg-prod-todoapp-01"
  location   = "centralindia"
  tags       = local.common_tags
}

module "aks" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_kubernetes_cluster"
  aks_name   = "aks-prod-todoapp"
  location   = "centralindia"
  rg_name    = "rg-prod-todoapp-01"
  dns_prefix = "aks-prod-todoapp"
  node_count = "1"
  vm_size    = "Standard_D4_v2"
  tags       = local.common_tags
}
