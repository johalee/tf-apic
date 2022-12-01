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

variable "apic" {
  type = map(any)
  default = {
    username = "admin"
    password = ""
    url      = ""
  }
}

# Define an ACI Tenant Resource.
resource "aci_tenant" "tenant1" {
  name        = "tenant_hands_on"
  description = "Created by terraform code"
}



resource "aci_bridge_domain" "bd_for_subnet" {
  tenant_dn   = aci_tenant.tenant1.id
  name        = "bd_for_subnet"
  description = "This bridge domain is created by the Terraform ACI provider"
}

resource "aci_subnet" "demosubnet" {
  parent_dn   = aci_bridge_domain.bd_for_subnet.id
  ip          = "172.16.1.1/24"
  scope       = ["private"]
  description = "This subject is created by Terraform v3"
}

resource "aci_application_profile" "myWebsite" {
  tenant_dn = aci_tenant.myTenant.id
  name      = "my_website"
}
resource "aci_application_epg" "web" {
  application_profile_dn = aci_application_profile.myWebsite.id
  name                   = "web"
  description            = "this is the web epg created by terraform"
  flood_on_encap         = "disabled"
  fwd_ctrl               = "none"
  has_mcast_source       = "no"
  match_t                = "AtleastOne"
  name_alias             = "web"
  pc_enf_pref            = "unenforced"
  pref_gr_memb           = "exclude"
  prio                   = "unspecified"
  shutdown               = "no"
}
resource "aci_application_epg" "db" {
  application_profile_dn = aci_application_profile.myWebsite.id
  name                   = "db"
  description            = "this is the database epg created by terraform"
  flood_on_encap         = "disabled"
  fwd_ctrl               = "none"
  has_mcast_source       = "no"
  match_t                = "AtleastOne"
  name_alias             = "db"
  pc_enf_pref            = "unenforced"
  pref_gr_memb           = "exclude"
  prio                   = "unspecified"
  shutdown               = "no"
}
