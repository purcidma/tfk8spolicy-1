#get the data fro the global vars WS
data "terraform_remote_state" "global" {
  backend = "remote"
  config = {
    organization = "Lab14"
    workspaces = {
      name = var.globalwsname
    }
  }
}

variable "globalwsname" {
  type        = string
  description = "TFCB workspace name that has all of the global variables"
}

terraform {
  required_providers {
    intersight = {
      source = "ciscodevnet/intersight"
      version = "1.0.8"
    }
  }
}

provider "intersight" {
  apikey    = "5981e8973e95200001018a24/59a844f6f11aa10001d90cdb/60cb8f3e7564612d302f8dfa"
  secretkey = "-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAnGZUZXUWQ2SlElltOZ1CI7SyINvZJg2BoZEhbicy41Xy6ymT
Oz6NUZnWWf0Rsrot6lx/isLLxaq5wJtbpsKua3tQo9mpAlyX2Lc7j8u/uu88EywP
rh22bbEY59zZiXa5gkC5FNOmJPAOFwZ1xdLTd+QQGD5ZHt+03rOV57iFR3c9OOel
NQ13rtRSu+sDs0eCReFzJDly/WUmo0hi0vwLc2+7s31h4KPYAGJv9yAPl3QflDEU
y049EC4t6vJ5+xG4BVqIaMf682Hkfu3paH1xfciVD9P3fWpz4sBrp5PVMpyXCDlZ
35lWaZyRaZkH/D78YAI9Nc2wisOuZfOMiEP1jwIDAQABAoIBAC9x135js5pEKNNV
L44/x3Wfdj4Dk284v69soHCTEZvnUebG2PQq+KHdgioQXFMUqaMj5kkI6NoQ/YKR
Xo9LFbBjW0YpXFzsC+BhTX9EtugVdOr3/dW7C8Fg7QZBd/h8fLAnxD2uKwOfkxan
Dgkx+JaxJ7TDDTQRdwPsBLijwEK6Tvi/kFpTF36TVsLKUfO0+/mNOD+8oFmgzlKg
4P70Xt7spj/CaZUMpIEJhObKP3bk7anuXiY+u1zPkpLsoyKG5QZz6fCI7b3oavxP
PY+D82kmZwNCCe+iq34nfol4odW9m4y5i08SER9pX2jnvam4EoryO3Di46Djuzx6
AsWcwrkCgYEAzIzXoVCbOEiudqlX1XKrsJ61TcsIBu/WDpOGuLQFpOlG5X7/zhRC
zSM4CP88zitduE9BJsdyoJudYpoNmwGJP7IfZDO0zzZWOZKG1C+g5V20zz/5uzdn
1sUOUIxblPDSWq6pJ8g3e6/NsMzeutsbxLVqkWAeYJ/KdNr9nIWj8U0CgYEAw70K
OCxA4YuvdHCcn1+Da/+EMuHd97WfXuPlajQdMzWupfbG+4bD45t0uhHsHIQY64bd
drFEzibu7iDCLj224hOH++keD5efw1QBSDQq94chllPMapT80U6j0RrYGO1QTabY
9gOWBygngmqLrj0sYdmVBsspDc/qRf3oNTbLVEsCgYEAmu4muQmbt+LdOgWEAKkN
QAbF3nlkyBRKttmo1ieMit8iEtvBl26jNktxuubQQHx6TQrCl0PEH8AeUjvLCFf+
g98/hZ7gWX6Xip3gP8EfhfsW409asSIDJZo2AG5/Q22wdn0KpJYy6B09l6dlIHSr
MLAUWq5J8/ez2hSwuShEB5UCgYA9+ILcx/3+qqfxGJotxyKnta0YIvSQsXr0oviG
SFuaU/uoZdoX1lH8pMIvCu+TE6uEHh3Nr1AWaLMqx0pTM4zMRNy/v82ZqCqXv+fs
AUA9QBY9LujAMc1dQyWQVYxnT/MlspZsRTRhra/clXkFwC5mCGorTXUA/3uvjzTO
bDuxwwKBgGSBjMXFCdC6ky2BsqQhxZEJXpfnKz8QxbG8IHZ91LiNzQAIyVP9TsKl
cKv+JQNqYe18+fUCowhCKtdaZ3/blflmz3qm8xaq2ZhG4i5epupDvGINBKZpS9vY
jj9B8j6M/u186dQAcmxB16lNiS4kdju6WL9SuQ1GMUF265/fLe0y
-----END RSA PRIVATE KEY-----
"
  endpoint = "https://intersight.com"
}

module "infra_config_policy" {
  source           = "terraform-cisco-modules/iks/intersight//modules/infra_config_policy"
  name             = local.infra_config_policy 
  device_name      = local.device_name
  vc_portgroup     = [local.portgroup]
  vc_datastore     = local.datastore
  vc_cluster       = local.vspherecluster
  vc_resource_pool = local.resource_pool
  vc_password      = local.password
  org_name         = local.organization
}

module "ip_pool_policy" {
  source           = "terraform-cisco-modules/iks/intersight//modules/ip_pool"
  name             = local.ip_pool_policy 
  starting_address = local.starting_address
  pool_size        = local.pool_size
  netmask          = local.netmask
  gateway          = local.gateway
  primary_dns      = local.primary_dns

  org_name = local.organization
}

module "network" {
  source      = "terraform-cisco-modules/iks/intersight//modules/k8s_network"
  policy_name = "sbcluster" 
  #policy_name = local.clustername
  dns_servers = [local.primary_dns]
  ntp_servers = [local.primary_dns]
  timezone    = local.timezone
  domain_name = local.domain_name
  org_name    = local.organization
}

module "k8s_version" {
  source           = "terraform-cisco-modules/iks/intersight//modules/version"
  k8s_version      = local.k8s_version 
  k8s_version_name = local.k8s_version_name 

  org_name = local.organization
}

data "intersight_organization_organization" "organization" {
  name = local.organization
}
resource "intersight_kubernetes_virtual_machine_instance_type" "masterinstance" {
  name      = local.masterinstance
  cpu       = local.cpu
  disk_size = local.disk_size
  memory    = local.memory
  organization {
    object_type = "organization.Organization"
    moid        = data.intersight_organization_organization.organization.results.0.moid
  }
}



locals {
  masterinstance = yamldecode(data.terraform_remote_state.global.outputs.masterinstance)
  cpu = yamldecode(data.terraform_remote_state.global.outputs.cpu)
  disk_size = yamldecode(data.terraform_remote_state.global.outputs.disk_size)
  memory = yamldecode(data.terraform_remote_state.global.outputs.memory)
  organization= yamldecode(data.terraform_remote_state.global.outputs.organization)
  k8s_version = yamldecode(data.terraform_remote_state.global.outputs.k8s_version)
  k8s_version_name = yamldecode(data.terraform_remote_state.global.outputs.k8s_version_name)
  clustername = yamldecode(data.terraform_remote_state.global.outputs.clustername)
  primary_dns = yamldecode(data.terraform_remote_state.global.outputs.primary_dns)
  timezone = yamldecode(data.terraform_remote_state.global.outputs.timezone)
  domain_name = yamldecode(data.terraform_remote_state.global.outputs.domain_name)
  ip_pool_policy = yamldecode(data.terraform_remote_state.global.outputs.ip_pool_policy)
  starting_address = yamldecode(data.terraform_remote_state.global.outputs.starting_address)
  pool_size = yamldecode(data.terraform_remote_state.global.outputs.pool_size)
  netmask = yamldecode(data.terraform_remote_state.global.outputs.netmask)
  gateway = yamldecode(data.terraform_remote_state.global.outputs.gateway)
  infra_config_policy = yamldecode(data.terraform_remote_state.global.outputs.infra_config_policy)
  device_name = yamldecode(data.terraform_remote_state.global.outputs.device_name)
  portgroup = yamldecode(data.terraform_remote_state.global.outputs.portgroup) 
  password = yamldecode(data.terraform_remote_state.global.outputs.password) 
#  portgroup = "VM Network" 
  datastore = yamldecode(data.terraform_remote_state.global.outputs.datastore)
  vspherecluster = yamldecode(data.terraform_remote_state.global.outputs.vspherecluster)
  resource_pool = yamldecode(data.terraform_remote_state.global.outputs.resource_pool)

}




















