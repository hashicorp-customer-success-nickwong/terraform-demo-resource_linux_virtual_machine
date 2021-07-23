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