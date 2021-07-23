output "managed_identity_principal_id" {
    value = azurerm_linux_virtual_machine.private.identity.0.principal_id
}