#!/bin/bash

# Function to prompt the user with a default value
prompt_with_default() {
    local prompt_message=$1
    local default_value=$2
    local user_input

    # Display the prompt message with the default value
    read -p "$prompt_message [$default_value]: " user_input

    # If the user input is empty, use the default value
    echo "${user_input:-$default_value}"
}

RESOURCE_GROUP_NAME=$(prompt_with_default "Enter Resource Group Name" "")
AZURE_DNS_ZONE=$(prompt_with_default "Enter DNS Zone Name" "")

AZURE_CERT_MANAGER_NEW_SP_NAME=cert-manager-sp

DNS_SP=$(az ad sp create-for-rbac --name $AZURE_CERT_MANAGER_NEW_SP_NAME --output json)
AZURE_CERT_MANAGER_SP_APP_ID=$(echo $DNS_SP | jq -r '.appId')
AZURE_CERT_MANAGER_SP_PASSWORD=$(echo $DNS_SP | jq -r '.password')
AZURE_TENANT_ID=$(echo $DNS_SP | jq -r '.tenant')
AZURE_SUBSCRIPTION_ID=$(az account show --output json | jq -r '.id')

az role assignment delete --assignee $AZURE_CERT_MANAGER_SP_APP_ID --role Contributor --resource-group $RESOURCE_GROUP_NAME

DNS_ID=$(az network dns zone show --name $AZURE_DNS_ZONE --resource-group $RESOURCE_GROUP_NAME --query "id" --output tsv)
az role assignment create --assignee $AZURE_CERT_MANAGER_SP_APP_ID --role "DNS Zone Contributor" --scope $DNS_ID

kubectl get namespace | grep -q cert-manager || kubectl create namespace cert-manager
kubectl create secret generic azuredns-config --from-literal=client-secret=$AZURE_CERT_MANAGER_SP_PASSWORD -n cert-manager
