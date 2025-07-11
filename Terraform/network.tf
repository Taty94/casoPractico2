resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-casopractico2"
    location            = var.location
    resource_group_name = var.resource_group_name
    address_space       = ["10.0.0.0/16"]

    depends_on = [ azurerm_resource_group.rg ]

    tags = {
      environment = "casopractico2"
    }
}  

resource "azurerm_subnet" "subnet" {
    name                 = "subnet-casopractico2"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-casopractico2"
  location            = var.location
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_resource_group.rg]

  tags = {
    environment = "casopractico2"
  }
}

resource "azurerm_network_security_rule" "ssh" {
    name                        = "SshRule"
    priority                    = 1001
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name = var.resource_group_name
    network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "inbound_rule" {
  name                        = "InRule"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "outbound_rule" {
  name                        = "AllowAllOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_public_ip" "ip" {
  name                = "ip-casopractico2"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  depends_on = [azurerm_resource_group.rg]

  tags = {
    environment = "casopractico2"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-casopractico2"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }

  tags = {
    environment = "casopractico2"
  }
}
  
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id

  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_security_group.nsg
  ]
  
}