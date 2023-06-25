#Criação do cluter AKS e repositório ACR.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks_resource_group" {
  name     = "aks-resource-group"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.aks_resource_group.location
  resource_group_name = azurerm_resource_group.aks_resource_group.name
  dns_prefix          = "aks-cluster"

  linux_profile {
    admin_username = "adminuser"
    ssh_key {
      key_data = var.key_data
    }
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
    load_balancer_profile {
      outbound_ip_address_ids = []
    }
  }
}

resource "azurerm_container_registry" "acregistry" {
  name                = "ricassioRegistry"
  resource_group_name = azurerm_resource_group.aks_resource_group.name
  location            = azurerm_resource_group.aks_resource_group.location
  sku                 = "Basic"
  admin_enabled       = false
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "acregistry_name" {
  value = azurerm_container_registry.acregistry
  sensitive = true
}
