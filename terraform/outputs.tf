output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "app_service_name" {
  value = azurerm_linux_web_app.main.name
}

output "app_service_default_hostname" {
  value = azurerm_linux_web_app.main.default_hostname
}

output "app_service_health_url" {
  value = "https://${azurerm_linux_web_app.main.default_hostname}/healthz"
}

output "cosmosdb_account_name" {
  value = azurerm_cosmosdb_account.main.name
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}
