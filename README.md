# azure-federated-identity-samples

## Access AKS cluster using Azure Federated Identity from Github Actions (OpenID Connect)

Inspired by a community contribution in (https://github.com/Azure/kubelogin/pull/81), it enables a new pattern to access AKS clusters from Github. Instead of creating credential for a service principal and storing it in Github, it utilizes Github's [OpenID Connect](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure) and [Azure Workload Identity Federation](https://docs.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation) to access AKS clusters using AAD/Aure RBAC in a password-free setting.

### Environment setup
In [setup.sh](setup.sh), these steps are performed:

1. Create an AKS cluster with Azure RBAC enabled.
2. Create AAD application and service principal.
3. Create role assignment to the created AKS cluster using `Azure Kubernetes Service RBAC Cluster Admin` role.
4. Create [federated identity credential](https://docs.microsoft.com/en-us/graph/api/application-post-federatedidentitycredentials?view=graph-rest-beta&tabs=http) using Microsoft Graph api. Note that `audience` has to be `api://AzureADTokenExchange` and the [format](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims) of `subject` claim.

### Github Actions
