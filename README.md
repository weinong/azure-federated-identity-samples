# azure-federated-identity-samples

## Access AKS cluster using Azure Federated Identity from Github Actions (OpenID Connect)

Inspired by a community contribution in (https://github.com/Azure/kubelogin/pull/81), it enables a new pattern to access AKS clusters from Github. Instead of creating credential for a service principal and storing it in Github, it utilizes Github's [OpenID Connect](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure) and [Azure Workload Identity Federation](https://docs.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation) to access AKS clusters using AAD/Azure RBAC in a password-free setting.

### Environment setup

In [setup.sh](setup.sh), these steps are performed:

1. Create an AKS cluster with Azure RBAC enabled.
2. Create [Managed Identity](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview). Take note of the Client ID.
3. Create role assignment to the created AKS cluster using `Azure Kubernetes Service RBAC Cluster Admin` role.
4. Create [federated identity credential](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust-user-assigned-managed-identity?pivots=identity-wif-mi-methods-azp). Note that `audience` has to be `api://AzureADTokenExchange` and the [format](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims) of `subject` claim varies based on your repo configuration.

### Github Actions

The sample Github Actions workflow, [access-aks.yml](.github/workflows/access-aks.yml), has prerequisites such that below Actions secrets need to be configured:

- AZURE_SUBSCRIPTION_ID is the subscription ID in which AKS cluster resides
- RESOURCE_GROUP_NAME is the resource group in which AKS cluster resides
- AKS_NAME is the AKS cluster name used in Environment setup
- AZURE_TENANT_ID is Microsoft Entra tenant ID
- AZURE_CLIENT_ID is the Client ID created in Environment setup

[This workflow](.github/workflows/access-aks.yml) performs these steps:

1. [Az login using workload identity federation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
2. Get kubeconfig
3. Get [kubelogin](https://github.com/Azure/kubelogin)
4. Convert kubeconfig into [exec plugin format with workload identity login mode](https://azure.github.io/kubelogin/concepts/login-modes/workloadidentity.html)
5. Run kubectl
6. Profit!

<img width="245" alt="Screenshot 2023-12-01 at 2 11 21 PM" src="https://github.com/weinong/azure-federated-identity-samples/assets/4204090/fe47f4f7-1358-48ea-8529-9b80dbed4242">
