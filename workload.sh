githubOrganizationName='bbiebates'
githubRepositoryName='bicep-training-test-using-github-actions'

applicationRegistrationDetails=$(az ad app create --display-name 'toy-website-test-bates')
applicationRegistrationObjectId=$(echo $applicationRegistrationDetails | jq -r '.id')
applicationRegistrationAppId=$(echo $applicationRegistrationDetails | jq -r '.appId')

az ad app federated-credential create \
   --id $applicationRegistrationObjectId \
   --parameters "{
	\"name\":\"toy-website-test--bates\",
	\"issuer\":\"https://token.actions.githubusercontent.com\",
	\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:environment:Website\",
	\"audiences\":[\"api://AzureADTokenExchange\"]
}"

az ad app federated-credential create \
   --id $applicationRegistrationObjectId \
   --parameters "{
	\"name\":\"toy-website-test--bates-branch\",
	\"issuer\":\"https://token.actions.githubusercontent.com\",
	\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",
	\"audiences\":[\"api://AzureADTokenExchange\"]
}"

resourceGroupResourceId=$(az group create --name BatesToyWebsiteTest --location westus3 --query id --output tsv)

az ad sp create --id $applicationRegistrationObjectId
az role assignment create \
  --assignee $applicationRegistrationAppId \
  --role Contributor \
  --scope /$resourceGroupResourceId

echo "AZURE_CLIENT_ID: $applicationRegistrationAppId"
echo "AZURE_TENANT_ID: $(az account show --query tenantId --output tsv)"
echo "AZURE_SUBSCRIPTION_ID: $(az account show --query id --output tsv)"