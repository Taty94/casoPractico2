variable "subscription_id" {
  description = "The subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "The tenant ID"
  type        = string
}

variable "resource_group_name" {
  default = "rg-casopractico2"
}

variable "location" {
  default = "East US"
}
