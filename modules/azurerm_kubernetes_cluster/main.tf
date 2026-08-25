resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = var.dns_prefix

  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size

    upgrade_settings {
      max_surge = "10%"
    }
  }

  api_server_access_profile {
    authorized_ip_ranges = [
      "20.204.42.239/32"
    ]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }
}
