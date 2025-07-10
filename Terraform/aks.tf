resource "azurerm_kubernetes_cluster" "aks" {
    name                = "aks-casopractico2"
    location            = var.location
    resource_group_name = var.resource_group_name
    dns_prefix          = var.dns_prefix
    sku_tier            = "Paid"

    default_node_pool {
        name       = "default"
        node_count = 1
        vm_size    = "Standard_D2_v2"
    }

    identity {
        type = "SystemAssigned"
    }
    role_based_access_control_enabled = true

    tags = {
        environment = "casopractico2"
    }
}

resource "azurerm_role_assignment" "acrpull" {
    principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
    role_definition_name             = "AcrPull"
    scope                            = azurerm_container_registry.acr.id
    skip_service_principal_aad_check = true

    
    depends_on = [
        azurerm_kubernetes_cluster.aks,
        azurerm_container_registry.acr
    ]

}