
# 1. Generar el par de claves SSH
resource "tls_private_key" "ssh_key" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

## 2. Registrar la clave pública en Azure como gestionada
# resource "azurerm_ssh_public_key" "ssh_key" {
#     name                = "ssh-key-casopractico2"
#     resource_group_name = var.resource_group_name
#     location            = var.location
#     public_key          = tls_private_key.ssh_key.public_key_openssh
# } 

# 3. Crear la máquina virtual usando la clave gestionada
resource "azurerm_linux_virtual_machine" "vm" {
    name                = "vm-casopractico2"
    location            = var.location
    resource_group_name = var.resource_group_name
    size                = "Standard_B1s"
    admin_username      = var.vm_admin_username
    network_interface_ids = [
        azurerm_network_interface.nic.id
    ]

    admin_ssh_key {
        username   = var.vm_admin_username
        public_key = tls_private_key.ssh_key.public_key_openssh
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "20_04-lts-gen2"
        version   = "latest"
    }

    tags = {
        environment = "casopractico2"
    }
}
