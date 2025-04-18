
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  required_version = ">=1.0.0"
}

provider "azurerm" {
  subscription_id = "b691c69b-aff1-4fe4-b0a8-677e09ce0277"
  tenant_id       = "ef6c5eb8-7c56-4c85-93b4-2c508b098b67"
  client_id       = "deb642ae-cfb9-44af-bbf7-57d6ca21b260"
  client_secret   = "qr08Q~wtN5yjuaUQXkfCLYaq7PGHnINN2ren_dn~"
  features {}
}

# Variables
variable "location" {
  default = "Central US"
}

variable "resource_group_name" {
  default = "rg-aks-acr2912"
}

variable "acr_name" {
  default = "kubernetesacr291201" 
}

variable "aks_cluster_name" {
  default = "mycluster291201"
}

variable "dns_prefix" {
  default = "myakscluster2912"
}

variable "node_count" {
  default = 2
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    Environment = "Development"
  }
}

# Role assignment to allow AKS to pull from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id

 
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}
