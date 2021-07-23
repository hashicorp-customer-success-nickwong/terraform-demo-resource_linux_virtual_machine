output "managed_identity_principal_id" {
    value = var.has_managed_identity? azurerm_linux_virtual_machine.private.identity.0.principal_id : ""
}