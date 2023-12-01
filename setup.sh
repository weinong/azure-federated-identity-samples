#!/bin/bash

set -e

# fill in below variables based on your Azure environment
SUBSCRIPTION_ID=""
RESOURCE_GROUP_NAME=""
LOCATION=""
AKS_NAME=""
MSI_NAME=""

# reference: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims
GH_SUBJECT="repo:weinong/azure-federated-identity-samples:ref:refs/heads/main"

az account set --subscription ${SUBSCRIPTION_ID}

# create resource group
az group create -n ${RESOURCE_GROUP_NAME} -l ${LOCATION}

# create AKS cluster with Azure RBAC
az aks create \
	-g ${RESOURCE_GROUP_NAME} \
	-n ${AKS_NAME} \
	--enable-aad \
	--enable-azure-rbac

az identity create -l ${LOCATION} -g ${RESOURCE_GROUP_NAME} -n ${MSI_NAME}

# get AKS cluster resource ID
AKS_RESOURCE_ID=$(az aks show \
	-g ${RESOURCE_GROUP_NAME} \
	-n ${AKS_NAME} -o tsv --query "id" || true)

SPN_OID=$(az identity show -g ${RESOURCE_GROUP_NAME} -n ${MSI_NAME} -o tsv --query "principalId" || true)

# Create role assignment to the cluster
# this allows the SP to list user credential and performs k8s operations
az role assignment create \
	--role "Azure Kubernetes Service RBAC Cluster Admin" \
	--scope ${AKS_RESOURCE_ID} \
	--assignee-object-id ${SPN_OID} \
	--assignee-principal-type ServicePrincipal

# Create federated identity credential on the AAD app
az identity federated-credential create -n fic --identity-name ${MSI_NAME} -g ${RESOURCE_GROUP_NAME} \
	--issuer https://token.actions.githubusercontent.com \
	--subject ${GH_SUBJECT} --audience api://AzureADTokenExchange
