# azure-federated-identity-samples

## Access AKS cluster using Azure Federated Identity from Github Actions (OpenID Connect)

Inspired by a community contribution in (https://github.com/Azure/kubelogin/pull/81), it enables a new pattern to access AKS clusters from Github. Instead of creating credential for a service principal and storing it in Github, it utilizes Github's [OpenID Connect](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure) and [Azure Workload Identity Federation](https://docs.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation) to access AKS clusters using AAD/Azure RBAC in a password-free setting.

### Environment setup
In [setup.sh](setup.sh), these steps are performed:

1. Create an AKS cluster with Azure RBAC enabled.
2. Create AAD application and service principal.
3. Create role assignment to the created AKS cluster using `Azure Kubernetes Service RBAC Cluster Admin` role.
4. Create [federated identity credential](https://docs.microsoft.com/en-us/graph/api/application-post-federatedidentitycredentials?view=graph-rest-beta&tabs=http) using Microsoft Graph api. Note that `audience` has to be `api://AzureADTokenExchange` and the [format](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims) of `subject` claim.

### Github Actions
The sample Github Actions workflow, [access-aks.yml](.github/workflows/access-aks.yml), has prerequisites such that below Actions secrets need to be configured:
* AZURE_SUBSCRIPTION_ID is the subscription ID in which AKS cluster resides
* RESOURCE_GROUP_NAME is the resource group in which AKS cluster resides
* AKS_NAME is the AKS cluster name used in Environment setup
* AZURE_TENANT_ID is Azure AD tenant ID
* AZURE_CLIENT_ID is the appID created in Environment setup

[This workflow](.github/workflows/access-aks.yml) performs these steps:
1. [Az login using workload identity federation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
2. Get kubeconfig
3. Get [kubelogin](https://github.com/Azure/kubelogin)
4. Convert kubeconfig into [exec plugin format with workload identity support](https://github.com/Azure/kubelogin#azure-workload-federated-identity-non-interactive)
5. Get id-token and save to a file
6. Run kubectl
7. Profit!

![image](https://user-images.githubusercontent.com/4204090/161405021-c59ccbb7-6180-48b0-bac4-8ac8e6946a2b.png)
