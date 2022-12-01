variable "vcenter" {
  type        = map
  default     = {
    username = ""
    password = ""
    url      = ""
  }
}

variable "datacenter_name" {
    type = string
    default = "DC1"

}

variable "host_virtual_switches" {
    type = map
    default = {
        terraform_vswith = {
            hosts = ["10.72.86.35", "10.72.86.36", "10.72.86.37", "10.72.86.38"]
            mtu = 1500
            network_adapters = ["vmnic5"]
            active_nics    = ["vmnic5"]
            standby_nics   = []

            port_groups = [{
                name = "pg_1200"
                vlan_id           = 1200
                allow_promiscuous = true
            }]

            # teaming_policy = "failover_explicit"

            # allow_promiscuous      = false
            # allow_forged_transmits = false
            # allow_mac_changes      = false

            # shaping_enabled           = true
            # shaping_average_bandwidth = 50000000
            # shaping_peak_bandwidth    = 100000000
            # shaping_burst_size        = 1000000000
            
        }
    }
}
