variable "project_name" {
  description = "Short name used to prefix/generate resource names"
  type        = string
  default     = "msdocs-node-mongo"
}

variable "environment" {
  description = "Deployment environment tag (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "centralus"
}

variable "app_service_sku" {
  description = "SKU for the Linux App Service Plan"
  type        = string
  default     = "B1"
}

variable "node_version" {
  description = "Node.js runtime version for the App Service"
  type        = string
  default     = "20-lts"
}

variable "cosmos_db_name" {
  description = "Database name inside the Cosmos DB Mongo account"
  type        = string
  default     = "azure-todo-app"
}

variable "tags" {
  description = "Common tags applied to every resource"
  type        = map(string)
  default = {
    project   = "nodejs-mongodb-jenkins-azure"
    managedBy = "terraform"
  }
}
