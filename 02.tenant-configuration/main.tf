terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
    }
  }
}

# Configure the provider with your Cisco APIC credentials.
provider "aci" {
  # APIC Username
  username = var.apic.username
  # APIC Password
  password = var.apic.password
  # APIC URL
  url      = var.apic.url
  insecure = true
}

# Define an ACI Tenant Resource.
resource "aci_tenant" "terraform_tenant" {
    name        = var.tenant.name    
    description = contains(keys(var.tenant), "description") ? var.tenant.description : null
    annotation  = contains(keys(var.tenant), "annotation") ? var.tenant.annotation : null
    name_alias  = contains(keys(var.tenant), "name_alias") ? var.tenant.name_alias : null
}

# Define an ACI Tenant VRF Resource.
resource "aci_vrf" "terraform_vrf" {
    for_each    = var.vrfs
    tenant_dn   = aci_tenant.terraform_tenant.id
    name        = each.key
    description        = contains(keys(each.value), "description") ? each.value.description : null
    annotation        = contains(keys(each.value), "annotation") ? each.value.annotation : null
    bd_enforced_enable        = contains(keys(each.value), "bd_enforced_enable") ? each.value.bd_enforced_enable : null
    ip_data_plane_learning        = contains(keys(each.value), "ip_data_plane_learning") ? each.value.ip_data_plane_learning : null
    knw_mcast_act        = contains(keys(each.value), "knw_mcast_act") ? each.value.knw_mcast_act : null
    name_alias        = contains(keys(each.value), "name_alias") ? each.value.name_alias : null
    pc_enf_dir        = contains(keys(each.value), "pc_enf_dir") ? each.value.pc_enf_dir : null
    pc_enf_pref        = contains(keys(each.value), "pc_enf_pref") ? each.value.pc_enf_pref : null
}

# Define an ACI Tenant BD Resource.
resource "aci_bridge_domain" "terraform_bd" {
    for_each    = var.bds
    name               = each.key
    tenant_dn          = aci_tenant.terraform_tenant.id
    relation_fv_rs_ctx = contains(keys(each.value), "vrf") ? aci_vrf.terraform_vrf[each.value.vrf].id : null
    description        = contains(keys(each.value), "description") ? each.value.description : null
    annotation        = contains(keys(each.value), "annotation") ? each.value.annotation : null
    optimize_wan_bandwidth        = contains(keys(each.value), "optimize_wan_bandwidth") ? each.value.optimize_wan_bandwidth : null
    arp_flood        = contains(keys(each.value), "arp_flood") ? each.value.arp_flood : null
    ep_clear        = contains(keys(each.value), "ep_clear") ? each.value.ep_clear : null
    ep_move_detect_mode        = contains(keys(each.value), "ep_move_detect_mode") ? each.value.ep_move_detect_mode : null
    host_based_routing        = contains(keys(each.value), "host_based_routing") ? each.value.host_based_routing : null
    intersite_bum_traffic_allow        = contains(keys(each.value), "intersite_bum_traffic_allow") ? each.value.intersite_bum_traffic_allow : null
    intersite_l2_stretch        = contains(keys(each.value), "intersite_l2_stretch") ? each.value.intersite_l2_stretch : null
    ip_learning        = contains(keys(each.value), "ip_learning") ? each.value.ip_learning : null
    ipv6_mcast_allow        = contains(keys(each.value), "ipv6_mcast_allow") ? each.value.ipv6_mcast_allow : null
    limit_ip_learn_to_subnets        = contains(keys(each.value), "limit_ip_learn_to_subnets") ? each.value.limit_ip_learn_to_subnets : null
    mac        = contains(keys(each.value), "mac") ? each.value.mac : null
    mcast_allow        = contains(keys(each.value), "mcast_allow") ? each.value.mcast_allow : null
    multi_dst_pkt_act        = contains(keys(each.value), "multi_dst_pkt_act") ? each.value.multi_dst_pkt_act : null
    name_alias        = contains(keys(each.value), "name_alias") ? each.value.name_alias : null
    bridge_domain_type        = contains(keys(each.value), "bridge_domain_type") ? each.value.bridge_domain_type : null
    unicast_route        = contains(keys(each.value), "unicast_route") ? each.value.unicast_route : null
    unk_mac_ucast_act        = contains(keys(each.value), "unk_mac_ucast_act") ? each.value.unk_mac_ucast_act : null
    unk_mcast_act        = contains(keys(each.value), "unk_mcast_act") ? each.value.unk_mcast_act : null
    vmac        = contains(keys(each.value), "vmac") ? each.value.vmac : null
    
}

# Define an ACI Tenant BD Subnet Resource.
resource "aci_subnet" "terraform_bd_subnet" {
    for_each = var.subnets
    parent_dn   = aci_bridge_domain.terraform_bd[each.value.bd].id
    description = null
    ip          = each.value.ip
}

# Define an ACI Filter Resource.
resource "aci_filter" "terraform_filter" {
    for_each    = var.filters
    tenant_dn   = aci_tenant.terraform_tenant.id
    description = "This is filter ${each.key} created by terraform"
    name        = each.value.filter
}

# Define an ACI Filter Entry Resource.
resource "aci_filter_entry" "terraform_filter_entry" {
    for_each      = var.filters
    filter_dn     = aci_filter.terraform_filter[each.key].id
    name          = each.value.entry
    ether_t       = "ipv4"
    prot          = each.value.protocol
    d_from_port   = each.value.port
    d_to_port     = each.value.port
}

# Define an ACI Contract Resource.
resource "aci_contract" "terraform_contract" {
    for_each      = var.contracts
    tenant_dn     = aci_tenant.terraform_tenant.id
    name          = each.value.contract
    description   = "Contract created using Terraform"
}

# Define an ACI Contract Subject Resource.
resource "aci_contract_subject" "terraform_contract_subject" {
    for_each                      = var.contracts
    contract_dn                   = aci_contract.terraform_contract[each.key].id
    name                          = each.value.subject
    relation_vz_rs_subj_filt_att  = [aci_filter.terraform_filter[each.value.filter].id]
}

# Define an ACI Application Profile Resource.
resource "aci_application_profile" "terraform_ap" {
    tenant_dn  = aci_tenant.terraform_tenant.id
    name       = var.ap
    description = "App Profile Created Using Terraform"
}

# Define an ACI Application EPG Resource.
resource "aci_application_epg" "terraform_epg" {
    for_each                = var.epgs
    application_profile_dn  = aci_application_profile.terraform_ap.id
    name                    = each.value.epg
    relation_fv_rs_bd       = aci_bridge_domain.terraform_bd[each.value.bd].id
    description             = "EPG Created Using Terraform"
}

# Associate the EPG Resources with a VMM Domain.
resource "aci_epg_to_domain" "terraform_epg_domain" {
    for_each              = var.epgs
    application_epg_dn    = aci_application_epg.terraform_epg[each.key].id
    #tdn   = "uni/vmmp-VMware/dom-aci_terraform_lab"
    tdn  = each.value.tdn
}

# Associate the EPGs with the contrats
resource "aci_epg_to_contract" "terraform_epg_contract" {
    for_each           = var.epg_contracts
    application_epg_dn = aci_application_epg.terraform_epg[each.value.epg].id
    contract_dn        = aci_contract.terraform_contract[each.value.contract].id
    contract_type      = each.value.contract_type
}

resource "aci_epg_to_static_path" "terraform_epg_static_path" {
    for_each        = var.epg_static_path
    application_epg_dn = aci_application_epg.terraform_epg[each.value.epg].id
    tdn  = each.value.tdn
    encap  = each.value.encap
    mode  = "regular"
}
