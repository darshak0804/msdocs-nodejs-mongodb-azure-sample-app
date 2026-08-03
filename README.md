# Deploy Node.js + MongoDB to Azure App Service using Jenkins

## Project Overview

This project demonstrates a complete CI/CD pipeline for deploying the
Azure sample Node.js + MongoDB application to Azure App Service.
Infrastructure is provisioned with Terraform, Continuous Integration
(CI) is handled by Jenkins, and Continuous Deployment (CD) automatically
deploys the application to Azure.

Repository:
https://github.com/Azure-Samples/msdocs-nodejs-mongodb-azure-sample-app

## Architecture

Developer -\> GitHub -\> Jenkins CI -\> Build -\> Test -\> Package -\>
Archive Artifact -\> Jenkins CD -\> Azure Login (Service Principal) -\>
Azure App Service -\> MongoDB -\> Health Check

------------------------------------------------------------------------

# Prerequisites

-   Azure Subscription
-   GitHub Account
-   Jenkins Server
-   Terraform
-   Azure CLI
-   Git
-   Node.js LTS
-   npm

## Azure Resources

-   Resource Group
-   App Service Plan (Linux)
-   Azure App Service
-   Storage Account (optional for Terraform state)

# Step 1 - Fork Repository

Fork the repository to your GitHub account and clone it.

``` bash
git clone https://github.com/<your-user>/msdocs-nodejs-mongodb-azure-sample-app.git
cd msdocs-nodejs-mongodb-azure-sample-app
```

# Step 2 - Provision Infrastructure using Terraform

Run:

``` bash
terraform init
terraform validate
terraform plan
terraform apply
```

Terraform provisions: - Resource Group - App Service Plan - Azure Web
App

# Step 3 - Create Azure Service Principal

``` bash
az ad sp create-for-rbac --name sp-jenkins-nodejs --role Contributor --scopes /subscriptions/<subscription-id>
```

Save: - Client ID - Client Secret - Tenant ID - Subscription ID

Store them as Jenkins credentials.

# Step 4 - Configure Jenkins

Install plugins: - Git - Pipeline - NodeJS - Credentials - Workspace
Cleanup

Configure: - Git - NodeJS - Azure CLI

# Continuous Integration (CI)

Stages: 1. Checkout source 2. Install dependencies

``` bash
npm install
```

3.  Build

``` bash
npm run build
```

4.  Test

``` bash
npm test
```

5.  Package

``` bash
zip -r app.zip .
```

6.  Archive Artifact

``` groovy
archiveArtifacts artifacts: 'app.zip'
```

# Continuous Deployment (CD)

1.  Copy artifact
2.  Azure Login

``` bash
az login --service-principal \
-u $AZURE_CLIENT_ID \
-p $AZURE_CLIENT_SECRET \
--tenant $AZURE_TENANT_ID
```

3.  Deploy

``` bash
az webapp deploy \
--resource-group <rg> \
--name <webapp> \
--src-path app.zip
```

4.  Verify

``` bash
curl https://<app>.azurewebsites.net/health
```

Expected: HTTP 200

# Repository Structure

``` text
terraform/
Jenkinsfile-CI
Jenkinsfile-CD
README.md
```

# Screenshot Placeholders

-   Terraform Apply
-   Azure Portal Resources
-   Jenkins Credentials
-   Jenkins CI Success
-   Archived Artifact
-   Jenkins CD Success
-   Azure Deployment
-   Application Running
-   Health Endpoint

# Troubleshooting

-   npm install failures: clear cache and verify Node version.
-   Azure login failures: verify service principal credentials.
-   Deployment failures: confirm App Service name and resource group.
-   MongoDB connectivity: verify connection string in App Settings.

# Future Improvements

-   SonarQube
-   Trivy
-   Docker
-   Azure Container Registry
-   GitHub Actions
