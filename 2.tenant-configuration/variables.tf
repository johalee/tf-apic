variable "apic" {
  type = map(any)
  default = {
    username = "admin"
    password = "cisco123"
    url      = "https://10.70.130.200"
  }
}

variable "tenant" {
  type = map(any)
  default = {
##johalee##tenant name
      name = "tf_tn"
      description = "created by Terraform"
    # annotation  = "tag_tenant"
    # name_alias  = "alias_tenant"
  }
}
variable "vrfs" {
    type    = map
    default = {
##johalee##vrf name
        "tf_vrf" = {
            description = "created by Terraform"
            # annotation             = "tag_vrf"
            # bd_enforced_enable     = "no"
            # ip_data_plane_learning = "enabled"
            # knw_mcast_act          = "permit"
            # name_alias             = "alias_vrf"
            # pc_enf_dir             = "egress"
            # pc_enf_pref            = "unenforced"
        }
    }
}

variable "bds" {
    type    = map
    default = {
##johalee## bd name - 2 line
        web_bd = {
            vrf = "tf_vrf"
        },
##johalee## bd name - 2 line
        db_bd = {
            vrf = "tf_vrf"
            #     description                 = "sample bridge domain"
            #     name                        = "demo_bd"
            #     optimize_wan_bandwidth      = "no"
            #     annotation                  = "tag_bd"
            #     arp_flood                   = "no"
            #     ep_clear                    = "no"
            #     ep_move_detect_mode         = "garp"
            #     host_based_routing          = "no"
            #     intersite_bum_traffic_allow = "yes"
            #     intersite_l2_stretch        = "yes"
            #     ip_learning                 = "yes"
            #     ipv6_mcast_allow            = "no"
            #     limit_ip_learn_to_subnets   = "yes"
            #     mac                         = "00:22:BD:F8:19:FF"
            #     mcast_allow                 = "yes"
            #     multi_dst_pkt_act           = "bd-flood"
            #     name_alias                  = "alias_bd"
            #     bridge_domain_type          = "regular"
            #     unicast_route               = "no"
            #     unk_mac_ucast_act           = "flood"
            #     unk_mcast_act               = "flood"
            #     vmac                        = "not-applicable"
	}
    }
}

variable "subnets" {
    type    = map
    default = {
        bd_1 = {
##johalee## subnet setting - 2 line
            bd = "web_bd"
            ip = "10.10.101.1/24"
            description = "created by Terraform"
        },
        bd_2 = {
            bd = "db_bd"
            ip = "10.10.102.1/24"
            description = "created by Terraform"
            # annotation       = "tag_subnet"
            # ctrl             = ["querier" "nd"]
            # name_alias       = "alias_subnet"
            # preferred        = "no"
            # scope            = ["private" "shared"]
            # virtual          = "yes"
        }

    }
}

variable "filters" {
  description = "Ccreated by Terraform"
  type        = map(any)
  default     = {
        filter_https = {
            filter   = "https"
            entry    = "https"
            protocol = "tcp"
            port     = "443"
        }
        filter_sql = {
            filter   = "sql"
            entry    = "sql"
            protocol = "tcp"
            port     = "1433"
        }
    }
}
variable "contracts" {
  description = "Create contracts with these filters"
  type        = map(any)
  default = {
    contract_web = {
      contract = "web"
      subject  = "https"
      filter   = "filter_https"
    }
    contract_sql = {
      contract = "sql"
      subject  = "sql"
      filter   = "filter_sql"
    }
  }
}

variable "ap" {
  description = "created by Terraform"
##johalee## subnet setting - 2 line
  default     = "tf_ap"
  type        = string
}

variable "epgs" {
  description = "created by Terraform"
  type        = map(any)
  default = {
    web_epg = {
      epg   = "web"
      bd    = "web_bd"
      tdn   = "uni/vmmp-VMware/dom-dc1_vds"
    },
    db_epg = {
      epg   = "db"
      bd    = "db_bd"
      tdn   = "uni/phys-physdom"
    }
  }
}

variable "epg_contracts" {
  description = "created by Terraform"
  type        = map(any)
  default = {
    contract_1 = {
      epg           = "web_epg"
      contract      = "contract_web"
      contract_type = "provider"
    },
    contract_2 = {
      epg           = "web_epg"
      contract      = "contract_sql"
      contract_type = "consumer"
    },
    contract_3 = {
      epg           = "db_epg"
      contract      = "contract_sql"
      contract_type = "provider"
    }
  }
}

variable "epg_static_path" {
  description = "created by Terraform"
  type        = map(any)
  default = {
    static_1 = {
      epg           = "db_epg"
      tdn           = "topology/pod-1/paths-101/pathep-[eth1/1]"
      encap         = "vlan-410"
    },
    static_2 = {
      epg           = "db_epg"
      tdn           = "topology/pod-1/paths-103/pathep-[eth1/1]"
      encap         = "vlan-400"
    },
    static_3 = {
      epg           = "db_epg"
      tdn           = "topology/pod-1/paths-102/pathep-[eth1/3]"
      encap         = "vlan-410"
    },
  }
}
