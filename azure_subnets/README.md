#### Requirements
| Name | Version |
|------|---------|
| Terraform | = 1.1.0 |
| Azurerm | = 2.87.0 |
| Module naming | = 5.0 |
| Module resource group | = 5.0 |
| Module virtual network | = 5.0 |

#### Inputs
| Name | Required | Type | Default | Description |
|------|----------|------|---------|-------------|
| naming | required | `map(string)` | none | set the ouputs names from naming module. e.g location, etc. |
| resource_group_name | required | `string` | none | Specifies the resource group name |
| virtual_network_name | required | `string` | none | The name of virtual network for create subnets inside. |
| subnets | required | `object` | none | This is where you configure the subnets, their names, prefixes (cidr), delegations, service_endpoints and nsg_rules (network security group rules). In the examples folder there is an example |

#### Outputs
| Name | Description |
|------|-------------|
| resource | All attributes of the main resource. |
| subnets_names | The name of each subnet. |
| subnets_ids | The id of each subnet. |
| nsgs | all information about the network security group. |
| nsgs_associations | The relationship between nsg and subnets. |
| nsgs_rules | all network security group rules.
| nsgs_ids | the network security ip list. |

#### How to use
There is a complete example inside the examples folder.


