# lab-01 - provisioning of lab resources

As always, we need to provision lab environment before we start working on the lab tasks. To make sure you have all resource providers required by lab resources, run the following commands.  

```powershell
# Make sure that all Resource Providers are registered
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Compute
az provider register --namespace microsoft.devtestlab
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

Estimated deployment time is 5-10 min. 


The following resources will be deployed in your subscription under the following resource groups:

### rg-norwayeast-avnm-labs
| Resource name | Type | Location |
|---------------|------|----------|
| x | x | x |



