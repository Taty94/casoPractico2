# Configure the Azure provider
terraform {
    required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 4.35.0"
        }
    }
    required_version = ">= 1.1.0"
}

provider "azurerm" {
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id
    features {}
}


