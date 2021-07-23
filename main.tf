variable "count" {
    type = number
    default = 1
}

variable "name_prefix" {
  type = string
  default = "vm-"
}

variable "resource_group_name" {
  type = string
}

variable "location" {
    type = string
}

variable "size" {
    type = string
    default = "Standard_B1"
}

variable "admin_username" {
    type = string
    default = "adminuser"
}

variable "cloud_init_script" {
    type = string
    default = ""
}

variable "ssh_public_key" {
    type = string
}

variable "source_image_version" {
    type = string
    default = "latest"
}

variable "source_image_name" {
    type = string
}

variable "source_image_gallery_name" {
    type = string
}

variable "source_image_gallery_resource_group_name" {
    type = string
}

variable "subnet_id" {
    type = string
}

variable "static_ip_addresses" {
  type = list(string)
}

variable "has_managed_identity" {
    type = bool
    default = false
}

variable "tags" {
    type = map(string)
}

data "azurerm_shared_image_version" "private" {
  name                = var.source_image_version
  image_name          = var.source_image_name
  gallery_name        = var.source_image_gallery_name
  resource_group_name = var.source_image_gallery_resource_group_name
}

resource "azurerm_network_interface" "private" {
  name                = "${var.name_prefix}nic-${count.index}"
  count               = var.count
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    primary                       = true
    private_ip_address            = var.static_ip_addresses[count.index]
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "private" {
  count               = var.count
  name                = "${var.name_prefix}${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username
  custom_data = var.cloud_init_script == "" ? null : base64encode(var.cloud_init_script)

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_Public_key
  }

  source_image_id = data.azurerm_shared_image_version.private.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface_ids = [
    azurerm_network_interface.vault[count.index].id,
  ]

  dynamic "identity" {
      for_each = var.has_managed_identity ? { managed_identity = "yes" } : {}
      content {
        type = "SystemAssigned"
      }
  }

  tags = var.tags
}

output "managed_identity_principal_ids" {
    value = azurerm_linux_virtual_machine.private.*.identity.0.principal_id
}