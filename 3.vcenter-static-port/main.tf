terraform {
  required_providers {
    vsphere = {
        source = "hashicorp/vsphere"
    }
  }
}

provider "vsphere" {
  user           = var.vcenter.username
  password       = var.vcenter.password
  vsphere_server = var.vcenter.url

  # If you have a self-signed cert
  allow_unverified_ssl = true
}


data "vsphere_host" "hosts" {
    for_each = {
        for switch in local.host_virtual_switches : switch.host => switch
    }
    name = each.key
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datacenter" "datacenter" {
    name = var.datacenter_name
}


locals {
    # flatten ensures that this local value is a flat list of objects, rather
    # than a list of lists of objects.
    host_virtual_switches = flatten([
        for switch_key, switch in var.host_virtual_switches : [
            for host in switch.hosts : {
                name = switch_key
                host = host
                mtu = switch.mtu
                network_adapters = switch.network_adapters
                active_nics = switch.active_nics
                standby_nics = switch.standby_nics
                # teaming_policy = switch.teaming_policy
                
            }
        ]
    ])
}

locals {
    # flatten ensures that this local value is a flat list of objects, rather
    # than a list of lists of objects.
    host_port_groups = flatten([
        for switch_key, switch in var.host_virtual_switches : [
            for host in switch.hosts : [
                for port_group in switch.port_groups: {
                    host = host
                    vswitch = switch_key
                    name = port_group.name
                    vlan_id = port_group.vlan_id
                    allow_promiscuous = port_group.allow_promiscuous
                }
            ]
        ]
    ])
}


resource "vsphere_host_virtual_switch" "switch" {
    for_each = {
        for switch in local.host_virtual_switches : "${switch.host}_${switch.name}" => switch
    }
    name           = each.value.name
    host_system_id = data.vsphere_host.hosts[each.value.host].id
    network_adapters = each.value.network_adapters
    active_nics  = each.value.active_nics
    standby_nics = []
    mtu = each.value.mtu
}


# resource "vsphere_host_port_group" "port_groups" {
#     for_each = {
#         for pg in local.host_port_groups : "${pg.host}_${pg.vswitch}_${pg.name}" => pg
#     }
#     name           = each.value.name
#     host_system_id = data.vsphere_host.hosts[each.value.host].id
#     virtual_switch_name = each.value.vswitch
#     vlan_id = each.value.vlan_id
#     allow_promiscuous = each.value.allow_promiscuous
# }

