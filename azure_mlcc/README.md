#### azurerm_machine_learning_compute_cluster
referencing the url `git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.mlcc?ref=1.1`.

#### Requirements
| Name | Version |
|------|---------|
| Terraform | >= 1.1.0 |
| Azurerm | >= 2.87.0 |
| Module naming | >= 5.0 |

#### Inputs
| Name | Required | Type | Default | Description |
|------|----------|------|---------|-------------|
| naming | required | `map(string)` | none | set the ouputs names from naming module. e.g location, tags, etc. |
| resource_group | required | `string` | none | Specifies the name of the Resource Group in which the Machine Learning Workspace should exist. Changing this forces a new resource to be created. |
| location | optional | `string` | module naming | Location of the cluster. |
| cluster_name | optional | `string` | none | The name of cluster. |
| vm_priority | optional | `string` | LowPriority | The priority of the VM. |
| vm_size | optional | `string` | Standard_DS2_v2 | The size of the VM. |
| machine_learning_workspace_id | optional | `string` | none | The id of the machine learning workspace. |
| subnet_resource_id | optional | `string` | none | The subnet id of the virtual network. |
| description | optional | `string` | none | The description of the compute cluster. |
| scale_settings | optional | `map(string)` | none | Specifies how scale the cluster. |
| ssh | optional | `map(string)` | none | set user and ssh key to access. |

#### Outputs
| Name | Description |
|------|-------------|
| object | All attributes of the main object. |
| name | Name of the main object. |
| id | ID of the main object. |

#### How to use
There is a complete example inside the examples folder.
