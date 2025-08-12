# lab-07 - Managing Virtual Networks IP addresses using AVNM IPAM

Before we start working with IP Address Management, we need to create new Address Pool in our Virtual Network Manager. This Address Pool will be used to manage IP addresses of our virtual networks.

## Task #1 - create new Address Pool    

Navigate to the `vnm-norwayeast-avnm-labs` Virtual Network Manager and select the `IP address management->IP address pools` section. Click on `Create` to create a new Address Pool.
![Create Address Pool](../../assets/images/lab-07/create-address-pool.png)

Fill in the following information:
| Field | Value |
|-------|-------|
| Name  | iac-main-pool |
| Display name | IAC Main Pool |
| Region | Norway East |
| Description | Main Address Pool for IAC labs |
| Parent pool | Keep empty |

![Create Address Pool form](../../assets/images/lab-07/create-address-pool-1.png)

Click `Next` to go to `IP addresses` section.

At the `IP addresses` section, Fill in the following information:
| Field | Value |
|-------|-------|
| IP address type | IPv4 |
| Starting address | 10.9.0.0 |
| Size | /16 |


![Create Address Pool form](../../assets/images/lab-07/create-address-pool-2.png)

Click `Review + create` and then `Create` to create the Address Pool.

After pool is created you will see it in the list of Address Pools.
![Address Pool list](../../assets/images/lab-07/create-address-pool-3.png)

## Task #2 - Associate `vnet-hub-norwayeast` VNet with Address Pool using Portal

To associate the virtual network with the address pool, navigate to the `vnm-norwayeast-avnm-labs/iac-main-pool` Address pool and select `Allocations` under `Settings` tab. Click on `Associate resources` to associate the virtual network with the address pool.

![Associate VNet](../../assets/images/lab-07/associate-vnet.png)

From the list of Virtual Networks, select `vnet-hub-norwayeast` and click `Associate`.
![Associate VNet form](../../assets/images/lab-07/associate-vnet-1.png)

