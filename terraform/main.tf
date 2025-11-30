# Configure the Azure Provider
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Lab"
    Project     = "AKS-Terraform-Demo"
    ManagedBy   = "Terraform"
  }
}

# Create Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${var.cluster_name}-dns"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
    
    # Enable auto-scaling (optional)
    # min_count  = 1
    # max_count  = 3
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "azure"
  }

  tags = {
    Environment = "Lab"
    Project     = "AKS-Terraform-Demo"
    ManagedBy   = "Terraform"
  }
}

# Output the kubeconfig
resource "local_file" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  filename   = "${path.module}/kubeconfig"
  content    = azurerm_kubernetes_cluster.aks.kube_config_raw
  
  # Make the file readable only by the owner
  file_permission = "0600"
}
