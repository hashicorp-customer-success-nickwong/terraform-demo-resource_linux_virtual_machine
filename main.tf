data "azurerm_shared_image_version" "private" {
  count               = var.source_image_name == null ? 0 : 1
  name                = var.source_image_version
  image_name          = var.source_image_name
  gallery_name        = var.source_image_gallery_name
  resource_group_name = var.source_image_gallery_resource_group_name
}

resource "azurerm_network_interface" "private" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    primary                       = true
    private_ip_address            = var.static_ip_address
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "private" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username
  custom_data         = var.cloud_init_script == "" ? null : base64encode(var.cloud_init_script)

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_id = var.source_image_name == null ? null : data.azurerm_shared_image_version.private[0].id

  dynamic "source_image_reference" {
   foreach = var.source_image_publisher == null ? {} : { image_count = 1 }
   content {
      publisher = var.source_image_publisher
      offer     = var.source_image_offer
      sku       = var.source_image_sku
      version   = var.source_image_version
   }
  }
  
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface_ids = [
    azurerm_network_interface.private.id,
  ]

  dynamic "identity" {
    for_each = var.has_managed_identity ? { managed_identity = "yes" } : {}
    content {
      type = "SystemAssigned"
    }
  }

  tags = var.tags
}
