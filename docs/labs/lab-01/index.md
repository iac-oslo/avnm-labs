# lab-01 - provisioning of lab resources

As always, we need to provision lab environment before we start working on the labs. To make sure you have all resource providers required by lab resources, run the following commands.  

```powershell
# Make sure that all Resource Providers are registered
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Compute
az feature register --namespace Microsoft.Compute --name EncryptionAtHost
az provider register -n Microsoft.Compute
```

Install required `az cli` extensions

```powershell
# Install virtual-network-manager extension
az extension add -n virtual-network-manager

# install bastion extension
az extension add -n bastion

# install ssh extension
az extension add -n ssh

# install azure-firewall extension
az extension add -n azure-firewall
```

## Task #1 - Provision lab environment

Let's clone lab repo and deploy the environment.  

```powershell
# Clone the repository to your local machine:
git clone https://github.com/iac-oslo/avnm-labs

# Navigate to iac folder
cd .\avnm-labs\iac

# Deploy the environment
./deploy.ps1
```

Estimated deployment time is 8-10 min. 

The following resources will be deployed in your subscription under `rg-westeurope-avnm-labs` resource group:

| Resource name | Type | 
|---------------|------|
| law-westeurope-avnm-labs | Log Analytics Workspace |
| nfp-westeurope | Firewall Policy |
| naf-westeurope | Azure Firewall |
| pip-naf-westeurope | Public IP used by Azure Firewall |
| bastion-westeurope | Azure Bastion Host (Standard)|
| pip-bastion-westeurope | Public IP used by Azure Bastion Host |
| vnm-westeurope-avnm-labs | Virtual Network Manager |
| vnet-hub-westeurope | Hub Virtual Network |
| vnet-spoke1-westeurope | Spoke1 Virtual Network |
| vnet-spoke2-westeurope | Spoke2 Virtual Network |
| vm-hub-westeurope | Hub Virtual Machine |
| vm-spoke1-westeurope | Spoke1 Virtual Machine |
| vm-spoke2-westeurope | Spoke2 Virtual Machine |

Provision script is implemented as Bicep template with use of [Azure Verified modules](https://azure.github.io/Azure-Verified-Modules/indexes/bicep/bicep-resource-modules/) for most of the resources (except Azure Bastion Host)

The following IP ranges are used for virtual networks:

| Virtual Network | IP Range |
|------------------|----------|
| vnet-hub-westeurope | 10.9.0.0/24 |
| vnet-spoke1-westeurope | 10.9.1.0/24 |
| vnet-spoke2-westeurope | 10.9.2.0/24 |


`vnet-hub-westeurope` contains four subnets:

| Subnet Name | IP Range |
|-------------|----------|
| AzureFirewallSubnet    | 10.9.0.0/26 |
| subAzureBastionSubnetnet2    | 10.9.0.64/26 |
| AzureFirewallManagementSubnet    | 10.9.0.192/26 |
| subnet-workload    | 10.9.0.128/26 |

## Allocated IP addresses

If you used the original script without changing it, most likely resources created under your subscription will be allocated with the same private IP addresses. Use scripts below to verify the allocated IP addresses. If they are different, you need to use your own IPs further in the labs.

### Azure Firewall Private IP

```powershell
# Get private IP of Azure Firewall
az network firewall show -g rg-westeurope-avnm-labs -n naf-westeurope --query ipConfigurations[0].privateIPAddress -o tsv
```

Azure Firewall private IP is `10.9.0.4`

### Virtual Machine IP addresses:

```powershell
# get private ip for vm-hub-westeurope
az vm show -d -g rg-westeurope-avnm-labs -n vm-hub-westeurope --query privateIps -o tsv

# get private ip for vm-spoke1-westeurope
az vm show -d -g rg-westeurope-avnm-labs -n vm-spoke1-westeurope --query privateIps -o tsv

# get private ip for vm-spoke2-westeurope
az vm show -d -g rg-westeurope-avnm-labs -n vm-spoke2-westeurope --query privateIps -o tsv

```

| VM | IP Range |
|------------------|----------|
| vm-hub-westeurope | 10.9.0.132 |
| vm-spoke1-westeurope | 10.9.1.4 |
| vm-spoke2-westeurope | 10.9.2.4 |

