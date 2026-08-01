resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  suffix   = random_string.suffix.result
  rg_name  = "rg-${var.project_name}-${var.environment}"
  app_name = "app-${var.project_name}-${local.suffix}"
  plan_name = "plan-${var.project_name}-${var.environment}"
  cosmos_name = "cosmos-${var.project_name}-${local.suffix}"
  kv_name  = "kv-${substr(local.suffix, 0, 6)}-${var.environment}"
}

resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------------------------
# Azure Cosmos DB for MongoDB API
# ---------------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "main" {
  name                = local.cosmos_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_mongo_database" "main" {
  name                = var.cosmos_db_name
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
}

# ---------------------------------------------------------------------------
# Key Vault - stores the Cosmos DB connection string
# ---------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                       = local.kv_name
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
}

resource "azurerm_key_vault_access_policy" "webapp" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.main.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_secret" "database_url" {
  name         = "DATABASE-URL"
  value        = azurerm_cosmosdb_account.main.connection_strings[0]
  key_vault_id = azurerm_key_vault.main.id
}

# ---------------------------------------------------------------------------
# App Service Plan + Linux Web App (Node.js)
# ---------------------------------------------------------------------------
resource "azurerm_service_plan" "main" {
  name                = local.plan_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = var.tags
}

resource "azurerm_linux_web_app" "main" {
  name                = local.app_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = var.node_version
    }
    always_on = var.app_service_sku != "F1" && var.app_service_sku != "D1"
    health_check_path = "/healthz"
  }

  app_settings = {
    "DATABASE_NAME"                        = var.cosmos_db_name
    "AZURE_COSMOS_CONNECTIONSTRING"        = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.database_url.versionless_id})"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"       = "false"
    "WEBSITE_NODE_DEFAULT_VERSION"         = "~20"
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Service principal for Jenkins CD authentication (created separately via
# `az ad sp create-for-rbac`, see README) - this role assignment scopes an
# existing SP down to just this resource group.
# ---------------------------------------------------------------------------
variable "jenkins_sp_object_id" {
  description = "Object ID of the service principal Jenkins uses to deploy. Leave blank to skip role assignment."
  type        = string
  default     = ""
}

resource "azurerm_role_assignment" "jenkins_deploy" {
  count                = var.jenkins_sp_object_id == "" ? 0 : 1
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = var.jenkins_sp_object_id
}
