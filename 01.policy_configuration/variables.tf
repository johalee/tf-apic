variable "apic" {
  type        = map
  default     = {
    username = "admin"
    password = ""
    url      = ""
  }
}

variable "vlan_pools" {
    type    = map
    default = {
        terraform_pool_1 = {
            alloc_mode  = "dynamic" # Allowed values: "dynamic", "static"
            # annotation  = "example"
            # name_alias  = "example"
        }
    }
}

variable "vlan_ranges" {
    type    = map
    default = {
        terraform_range_1 = {
            vlan_pool = "terraform_pool_1"
            from  = "vlan-2000"
            to  = "vlan-2000"
            alloc_mode  = "static" # Allowed values: "dynamic", "static", "inherit"
            # annotation  = "example"
            # name_alias  = "example"
            # role  = "example" # Allowed values: "external", "internal"
        },
        terraform_range_2 = {
            vlan_pool = "terraform_pool_1"
            from  = "vlan-2100"
            to  = "vlan-2200"
            alloc_mode  = "dynamic" # Allowed values: "dynamic", "static", "inherit"
            # annotation  = "example"
            # name_alias  = "example"
            # role  = "example" # Allowed values: "external", "internal"
        }
    }        
}

variable "physical_domains" {
    type    = map
    default = {
        terraform_physdom_1 = {
            vlan_pool = "terraform_pool_1"
            # annotation  = "example"
            # name_alias  = "example"
        }
    }        
}

variable "aaeps" {
    type    = map
    default = {
        terraform_aaep_1 = {
            physdom = ["terraform_physdom_1"]
            # annotation  = "example"
            # name_alias  = "example"
        }
    }        
}

variable "link_level_policies" {
    type    = map
    default = {
        "terraform_ll_pol" = {
            # annotation = ""
            # auto_neg = "" # Allowed values: "on", "off"
            # fec_mode = "" # Allowed values: "inherit", "cl91-rs-fec", "cl74-fc-fec", "ieee-rs-fec", "cons16-rs-fec", "kp-fec", "disable-fec".
            # link_debounce = ""
            # name_alias = ""
            speed = "1G" # Allowed values: "unknown", "100M", "1G", "10G", "25G", "40G", "50G", "100G","200G", "400G", "inherit".
        }
    }        
}

variable "l2_interface_policies" {
    type    = map
    default = {
        "terraform_l2_pol" = {
            # description = "%s"
            # annotation  = "tag_l2_pol"
            # name_alias  = "alias_l2_pol"
            # qinq        = "disabled"
            # vepa        = "disabled"
            # vlan_scope  = "global"
        }
    }        
}

variable "lldp_policies" {
    type    = map
    default = {
        "terraform_lldp_pol" = {
            # description = "%s"
            # admin_rx_st = "%s"
            # admin_tx_st = "enabled"
            # annotation  = "tag_lldp"
            # name_alias  = "alias_lldp"
        }
    }        
}

variable "cdp_policies" {
    type    = map
    default = {
        "terraform_cdp_pol" = {
            # description = "%s"
            # admin_st  = "example"
            # annotation  = "tag_lldp"
            # name_alias  = "alias_lldp"
        }
    }        
}

variable "leaf_access_port_policy_groups" {
    type    = map
    default = {
        "terraform_leaf_policy_group" = {
            link_level_policy = "terraform_ll_pol"
            l2_interface_policy = "terraform_l2_pol"
            lldp_policy = "terraform_lldp_pol"
            cdp_policy = "terraform_cdp_pol"
            aaep = "terraform_aaep_1"
        }
    }        
}

variable "leaf_interface_profiles" {
    type    = map
    default = {
        "terraform-LEAF-101" = {
            # description = "%s"
            # annotation  = "tag_leaf"
            # name_alias  = "%s"
        }
    }        
}

variable "leaf_profiles" {
    type    = map
    default = {
        "terraform-leaf_profile" = {
            # description = "%s"
            # annotation  = "tag_leaf"
            # name_alias  = "%s"
            leaf_selectors = {
                terraform_leaf_selector_1 = {
                    policy_group = "terraform_leaf_policy_group"
                    switch_association_type = "range" # Allowed values: "ALL", "range", "ALL_IN_POD"
                    node_blocks = {
                        # blk1 = {
                        #     from_ = "105"
                        #     to_ = "106"
                        # },
                        blk2 = {
                            from_ = "102"
                            to_ = "104"
                        }
                    }
                },
                terraform_leaf_selector_2 = {
                    switch_association_type = "range"
                    node_blocks = {
                        blk1 = {
                            from_ = "105"
                            to_ = "107"
                        }
                    }
                }
            }
        }
    }        
}
