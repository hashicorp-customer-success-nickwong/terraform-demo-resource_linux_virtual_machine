output "managed_identity_principal_ids" {
    value = azurerm_linux_virtual_machine.private.*.identity.0.principal_id
}