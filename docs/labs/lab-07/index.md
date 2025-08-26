# lab-07 - cleaning up resources

This is the most important part of the workshop. We need to clean up all resources that we provisioned during the workshop to avoid unexpected bills.

## Task #1 - delete lab infrastructure

Remove all resources that were created during the workshop by running the following commands:

```powershell
az group delete --name rg-westeurope-avnm-labs --yes --no-wait

$subscriptionId = (az account show --query id --output tsv)
# remove policy assignment
az policy assignment delete --name spokes-westeurope --scope /subscriptions/$subscriptionId

# remove policy definition
az policy definition delete --name spokes-westeurope --subscription $subscriptionId
```