resource "azurerm_resource_group" "rg" {

  name = var.resource_group_name

  location = var.location

}


resource "azurerm_service_plan" "appservice" {

  name = "${var.app_name}-plan"

  resource_group_name = azurerm_resource_group.rg.name

  location = azurerm_resource_group.rg.location

  os_type = "Linux"

  sku_name = "B1"

  worker_count = 1
}


resource "azurerm_linux_web_app" "webapp" {

  name = var.app_name

  resource_group_name = azurerm_resource_group.rg.name

  location = azurerm_resource_group.rg.location

  service_plan_id = azurerm_service_plan.appservice.id


  site_config {

    application_stack {

      node_version = "22-lts"

    }

  }

}