# lab-03 - Segmenting virtual networks with Network Groups

Before you start configuring connectivity, security and routing across your networks, you first need to group virtual networks into Network Groups.

A network group is global container that includes a set of virtual network resources from any region. Group membership is a many-to-many relationship, such that one group holds many virtual networks and any given virtual network can participate in multiple network groups. There are two types of memberships: static and dynamic memberships.

In this lab we will create two Network Groups: 
- `ng-spokes-westeurope` - this group will be dynamic group containing all existing and future spokes Virtual Networks
- `ng-online-westeurope` - this group will be static group containing online Virtual Network

## Task #1 - create dynamic Network Group `ng-spokes-westeurope` for spokes VNets using Azure portal

For dynamic group, we will use convention that all Virtual Networks with name containing `spoke` will be automatically added to this group.

Navigate to `Network Groups` section in the Azure portal and click on `Create` to create a new Network Group.

![Create Network Group](../../assets/images/lab-03/network-group-1.png)

Fill in the following information:

| Field | Value |
|-------|-------|
| Name  | ng-spokes-westeurope |
| Description  | All Spoke VNets  |
| Member type | Select Virtual Network |

![Create Network Group](../../assets/images/lab-03/network-group-2.png)

Click `Create` and wait for the deployment to complete. When complete, open `ng-spokes-westeurope` group and navigate to `Settings -> Group members` page and click `Create Azure Policy`.

![Create Network Group](../../assets/images/lab-03/network-group-3.png)

Fill in the following information:

| Field | Value |
|-------|-------|
| Policy Name  | spokes-westeurope |
| Scope  | Select scope (Subscription(s), Management Group or Resource group) at which policy rules will be evaluated against |

At the `Criteria` section fill in policy rule criteria

| Field | Value |
|-------|-------|
| Parameter  | Select `Name` |
| Operator  | Select `Contains` |
| Condition  | Enter `spoke` |

![Create Network Group](../../assets/images/lab-03/network-group-4.png)

Click `Preview resources` to see the resources that will be included in the group. You should see the following VNets in the list.

![Create Network Group](../../assets/images/lab-03/network-group-5.png)

Click `Save`.

It may take some minutes for the policy to be applied and for the group to be populated with the existing VNets. While we are waiting, you can check that new Policy Definition 

![Create Network Group](../../assets/images/lab-03/network-group-6.png)

and Policy assignments were created successfully.

![Create Network Group](../../assets/images/lab-03/network-group-7.png)

Now, go back to `vnm-westeurope-avnm-labs/ng-spokes-westeurope` Network group and check `Settings -> Group members` page. You should see that the group is populated with existing spoke VNets.

![Create Network Group](../../assets/images/lab-03/network-group-8.png)


## Task #2 - create new spoke VNet and check that it was added into the Network Group

Let's create new `vnet-spoke3-westeurope` Virtual Network using `az cli`. We will use existing IPAM for address reservation.

```powershell
# Get iac-main IP pool resource Id
$ipamPoolId = (az network manager ipam-pool show -n iac-main --network-manager-name vnm-westeurope-avnm-labs -g rg-westeurope-avnm-labs --query id -o tsv)

# Create new spoke VNet with IP range from iac-main IP pool
az network vnet create -n vnet-spoke3-westeurope --resource-group rg-westeurope-avnm-labs --ipam-allocations [0].number-of-ip-addresses=10 [0].id=$ipamPoolId 
```

Note! It may take some minutes for policy to take effect, sometimes a lot of minutes :) 

Navigate to `vnm-westeurope-avnm-labs/ng-spokes-westeurope` Network Group in a few minutes and check `Group members` page. You should see new VNet added to the group by the Policy. 

If you don't see new VNet in the list, move on to the next task and get back when you done with all tasks from lab3.

## Task #3 - create new Network Group for hub VNet using `az cli`

```powershell
# Create new Network Group for hub VNet
az network manager group create --network-manager vnm-westeurope-avnm-labs -g rg-westeurope-avnm-labs -n ng-hub-westeurope --description "Virtual Network for Hub"

# Get hub VNet resource id
$hubVNetId = (az network vnet show -n vnet-hub-westeurope -g rg-westeurope-avnm-labs --query id -o tsv)

# Add hub VNet to the group
az network manager group static-member create --name hub-vnet --network-group ng-hub-westeurope --network-manager vnm-westeurope-avnm-labs -g rg-westeurope-avnm-labs --resource-id $hubVNetId
```

## Task #4 - create new static Network Group for online VNets using Bicep

In this task we will create a new static Network Group called `ng-online-westeurope` for all online Virtual Networks.

Create new file `online-ng.bicep` with the following content:

```bicep
resource networkManager 'Microsoft.Network/networkManagers@2024-07-01' existing = {
  name: 'vnm-westeurope-avnm-labs'
}

resource onlineNetworkGroup 'Microsoft.Network/networkManagers/networkGroups@2024-07-01' = {
  parent: networkManager
  name: 'ng-online-westeurope'
  properties: {
    description: 'Virtual Networks for Online workloads'
    memberType: 'VirtualNetwork'
  }
}

resource onlineVNet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: 'vnet-online1-westeurope'
}


resource onlineVNetMember 'Microsoft.Network/networkManagers/networkGroups/staticMembers@2024-07-01' = {
  name: 'online1-vnet'
  parent: onlineNetworkGroup
  properties: {
    resourceId: onlineVNet.id
  }
}
```

Deploy it

```powershell
# Make sure that you are at the folder where task6.bicep file is located
pwd

# Deploy task6.bicep file
az deployment group create --resource-group rg-westeurope-avnm-labs --template-file online-ng.bicep

# Check members list of ng-online-westeurope Network Group
az network manager group static-member list --network-group ng-online-westeurope --network-manager vnm-westeurope-avnm-labs -g rg-westeurope-avnm-labs --query [].name -o tsv
```