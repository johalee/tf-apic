terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
    }
  }
}

# Configure the provider with your Cisco APIC credentials.
provider "aci" {
    username = var.apic.username
    password = var.apic.password
    url      = var.apic.url
    insecure = true
}

resource "aci_vlan_pool" "terraform_vlan_pool" {
    for_each    = var.vlan_pools
    name        = each.key
    alloc_mode        = contains(keys(each.value), "alloc_mode") ? each.value.alloc_mode : null
    annotation        = contains(keys(each.value), "annotation") ? each.value.annotation : null
    name_alias        = contains(keys(each.value), "name_alias") ? each.value.name_alias : null
}

resource "aci_ranges" "terraform_range" {
    for_each    = var.vlan_ranges
    vlan_pool_dn  = aci_vlan_pool.terraform_vlan_pool[each.value.vlan_pool].id
    from  = each.value.from
    to  = each.value.to
    alloc_mode        = contains(keys(each.value), "alloc_mode") ? each.value.alloc_mode : null
    annotation        = contains(keys(each.value), "annotation") ? each.value.annotation : null
    name_alias        = contains(keys(each.value), "name_alias") ? each.value.name_alias : null
    role        = contains(keys(each.value), "role") ? each.value.role : null
}

resource "aci_physical_domain" "terraform_physical_domain" {
    for_each    = var.physical_domains
    name  = each.key
    annotation        = contains(keys(each.value), "annotation") ? each.value.annotation : null
    name_alias        = contains(keys(each.value), "name_alias") ? each.value.name_alias : null
    relation_infra_rs_vlan_ns = contains(keys(each.value), "vlan_pool") ? aci_vlan_pool.terraform_vlan_pool[each.value.vlan_pool].id : null
    # relation_infra_rs_vlan_ns_def   = "example"
    # relation_infra_rs_vip_addr_ns   = "example"
    # relation_infra_rs_dom_vxlan_ns_def   = "example"
}

resource "aci_attachable_access_entity_profile" "terraform_aaep" {
    for_each    = var.aaeps
    name  = each.key
    annotation        = contains(keys(each.value), "annotation") ? each.value.annotation : null
    name_alias        = contains(keys(each.value), "name_alias") ? each.value.name_alias : null
    relation_infra_rs_dom_p = [for domain in each.value.physdom : aci_physical_domain.terraform_physical_domain[domain].id]
}

resource "aci_fabric_if_pol" "terraform_link_level_policy" {
    for_each    = var.link_level_policies
    name  = each.key
    annotation        = contains(keys(each.value), "annotation") ? each.value.annotation : null
    auto_neg        = contains(keys(each.value), "auto_neg") ? each.value.auto_neg : null
    fec_mode        = contains(keys(each.value), "fec_mode") ? each.value.fec_mode : null
    link_debounce        = contains(keys(each.value), "link_debounce") ? each.value.link_debounce : null
    name_alias        = contains(keys(each.value), "name_alias") ? each.value.name_alias : null
    speed        = contains(keys(each.value), "speed") ? each.value.speed : null
}

resource "aci_l2_interface_policy" "terraform_l2_policy" {
    for_each    = var.l2_interface_policies
    name  = each.key
    description        = contains(keys(each.value), "description") ? each.value.description : null
    annotation        = contains(keys(each.value), "annotation") ? each.value.annotation : null
    name_alias        = contains(keys(each.value), "name_alias") ? each.value.name_alias : null
    qinq        = contains(keys(each.value), "qinq") ? each.value.qinq : null
    vepa        = contains(keys(each.value), "vepa") ? each.value.vepa : null
    vlan_scope        = contains(keys(each.value), "vlan_scope") ? each.value.vlan_scope : null
}

resource "aci_lldp_interface_policy" "terraform_lldp_policy" {
    for_each    = var.lldp_policies
    name  = each.key
    description        = contains(keys(each.value), "description") ? each.value.description : null
    admin_rx_st        = contains(keys(each.value), "admin_rx_st") ? each.value.admin_rx_st : null
    admin_tx_st        = contains(keys(each.value), "admin_tx_st") ? each.value.admin_tx_st : null
    annotation        = contains(keys(each.value), "annotation") ? each.value.annotation : null
    name_alias        = contains(keys(each.value), "name_alias") ? each.value.name_alias : null
}

resource "aci_cdp_interface_policy" "terraform_cdp_policy" {
    for_each    = var.cdp_policies
    name  = each.key
    description        = contains(keys(each.value), "description") ? each.value.description : null
    admin_st        = contains(keys(each.value), "admin_st") ? each.value.admin_st : null
    annotation        = contains(keys(each.value), "annotation") ? each.value.annotation : null
    name_alias        = contains(keys(each.value), "name_alias") ? each.value.name_alias : null
}

resource "aci_leaf_access_port_policy_group" "terraform_leaf_access_port_policy_group" {
    for_each    = var.leaf_access_port_policy_groups
    name  = each.key
    relation_infra_rs_h_if_pol      = contains(keys(each.value), "link_level_policy") ? aci_fabric_if_pol.terraform_link_level_policy[each.value.link_level_policy].id : null
    relation_infra_rs_l2_if_pol     = contains(keys(each.value), "l2_interface_policy") ? aci_l2_interface_policy.terraform_l2_policy[each.value.l2_interface_policy].id : null
    relation_infra_rs_lldp_if_pol   = contains(keys(each.value), "lldp_policy") ? aci_lldp_interface_policy.terraform_lldp_policy[each.value.lldp_policy].id : null
    relation_infra_rs_cdp_if_pol    = contains(keys(each.value), "cdp_policy") ? aci_cdp_interface_policy.terraform_cdp_policy[each.value.cdp_policy].id : null
    relation_infra_rs_att_ent_p     = contains(keys(each.value), "aaep") ? aci_attachable_access_entity_profile.terraform_aaep[each.value.aaep].id : null
}

resource "aci_leaf_interface_profile" "terraform_leaf_interface_profile" {
    for_each    = var.leaf_interface_profiles
    name  = each.key
    description        = contains(keys(each.value), "description") ? each.value.description : null
    annotation        = contains(keys(each.value), "annotation") ? each.value.annotation : null
    name_alias        = contains(keys(each.value), "name_alias") ? each.value.name_alias : null
}

resource "aci_leaf_profile" "example" {

    for_each    = var.leaf_profiles
    name  = each.key
    description        = contains(keys(each.value), "description") ? each.value.description : null
    annotation        = contains(keys(each.value), "annotation") ? each.value.annotation : null
    name_alias        = contains(keys(each.value), "name_alias") ? each.value.name_alias : null
    
    dynamic "leaf_selector" {
      for_each = contains(keys(each.value), "leaf_selectors") ? each.value.leaf_selectors : null
      content {
        name                    = leaf_selector.key
        switch_association_type = contains(keys(leaf_selector.value), "switch_association_type") ? leaf_selector.value.switch_association_type : null
        
        dynamic "node_block" {
            for_each = contains(keys(leaf_selector.value), "node_blocks") ? leaf_selector.value.node_blocks : null
            content {
                name = node_block.key
                from_  = contains(keys(node_block.value), "from_") ? node_block.value.from_ : null
                to_  = contains(keys(node_block.value), "to_") ? node_block.value.to_ : null
                
            }
        }
      }
    }

}