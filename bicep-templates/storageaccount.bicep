@description('Enter a name for the storage account')
param storageAccountName string

@description('Enter a location to deploy the account to')
param location string

@description('Enter the storage account sku')
param sku string

resource storageaccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
    name: storageAccountName
    location: location
    kind: 'StorageV2'
    sku: {
        name: sku
    }
    tags: {
        displayName: storageAccountName
    }
}

output BlobUri string = storageaccount.properties.primaryEndpoints.blob



