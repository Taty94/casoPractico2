resource "azurerm_container_registry" "acr" {
    name                = "acrcasopractico2${random_string.acr_suffix.result}"
    resource_group_name = var.resource_group_name
    location            = var.location
    sku                 = "Basic"
    admin_enabled       = true

    tags = {
        environment = "casopractico2"
    }
}

resource "random_string" "acr_suffix" {
    length  = 6
    upper   = false
    special = false
}
