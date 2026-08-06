output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "app_service_name" {
  value = azurerm_linux_web_app.webapp.name
}

output "app_service_default_hostname" {
  value = azurerm_linux_web_app.webapp.default_hostname
}

output "app_service_health_url" {
  value = "https://${azurerm_linux_web_app.webapp.default_hostname}/healthz"
}