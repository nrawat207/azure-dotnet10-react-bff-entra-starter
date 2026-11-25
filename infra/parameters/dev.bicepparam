using '../main.bicep'
param namePrefix = 'azstarter'
param environment = 'dev'
param location = 'centralindia'
param containerImage = 'mcr.microsoft.com/k8se/quickstart:latest' // Replace with your ACR image before deployment.
param entraTenantId = '<tenant-guid>'
param entraClientId = '<application-guid>'
param entraClientSecret = readEnvironmentVariable('ENTRA_CLIENT_SECRET')
