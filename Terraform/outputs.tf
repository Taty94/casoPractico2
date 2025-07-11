output "resource_group_name" {
  description = "Nombre del grupo de recursos"
  value       = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  description = "URL del Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "aks_cluster_name" {
  description = "Nombre del clúster AKS"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config" {
  description = "Configuración del clúster AKS"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "vm_name" {
  description = "Nombre de la máquina virtual"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_public_ip" {
  description = "IP pública de la máquina virtual"
  value       = azurerm_public_ip.ip.ip_address
}

output "vnet_name" {
  description = "Nombre de la red virtual"
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_id" {
  description = "ID de la subred"
  value       = azurerm_subnet.subnet.id
}

output "nic_id" {
  description = "ID de la interfaz de red"
  value       = azurerm_network_interface.nic.id
}

output "nsg_name" {
  description = "Nombre del grupo de seguridad de red"
  value       = azurerm_network_security_group.nsg.name
}

output "ssh_public_key" {
  description = "Clave pública SSH generada"
  value       = tls_private_key.ssh_key.public_key_openssh
}

output "ssh_private_key" {
  description = "Clave privada SSH generada"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}




