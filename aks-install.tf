data "azuread_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "aks-resource-group"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.1.0/24"]
  service_endpoints    = ["Microsoft.ContainerRegistry"]
}

# resource "azuread_group" "aks-admin-group" {
#   display_name     = "AKS-Aadmins"
#   owners           = [data.azuread_client_config.current.object_id]
# }



resource "azurerm_kubernetes_cluster" "aks" {
  name                = "myAKSCluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "someapplication"
  default_node_pool {
    name                  = "default"
    vnet_subnet_id        = azurerm_subnet.subnet.id
    type                  = "VirtualMachineScaleSets"
    availability_zones    = ["1", "3"]
    enable_auto_scaling   = true
    enable_node_public_ip = false
    max_count             = 3
    min_count             = 1
    os_disk_size_gb       = 256
    vm_size               = "standard_a2_v2"
  }
  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed                = true
      # admin_group_object_ids = [azuread_group.aks-admin-group.id]
    }
  }
  identity {
    type = "SystemAssigned"
  }
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "Standard"
  }

  addon_profile {
    aci_connector_linux {
      enabled = false
    }

    azure_policy {
      enabled = true
    }

    http_application_routing {
      enabled = false
    }

    # kube_dashboard {
    #   enabled = true
    # }
  }
}
