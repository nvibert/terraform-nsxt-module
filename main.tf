terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
    }
  }
  required_version = ">= 0.13"
}

provider "nsxt" {
  host                 = var.host
  vmc_token            = var.vmc_token
  allow_unverified_ssl = true
  enforcement_point    = "vmc-enforcementpoint"
}


/*===========
Get SDDC data
============*/


data "nsxt_policy_transport_zone" "TZ" {
  display_name = var.TransportZone
}


/*==============
Create segments
===============*/

resource "nsxt_policy_segment" "sampleSegment" {
  display_name        = "sample Segment"
  description         = "Terraform provisioned Segment"
  connectivity_path   = "/infra/tier-1s/cgw"
  transport_zone_path = data.nsxt_policy_transport_zone.TZ.path
  subnet {
    cidr              = var.SubnetGateway
    dhcp_ranges       = [var.SubnetRange]
  }
}

/*========================================
Create Security Group based on IP address
=========================================*/


resource "nsxt_policy_group" "ip-address-based-group" {
  display_name = "ip-address based group"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.Subnet]
    }
  }
}

/*=====================================
Create Security Group based on VM Name
======================================*/
  
resource "nsxt_policy_group" "name-based-group" {
  display_name = "name-based group"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
      condition {
            key         = "Name"
            member_type = "VirtualMachine"
            operator    = "CONTAINS"
            value       = var.NameCriteria
        }
    }
  
  
}


/*=====================================
Create Security Group based on NSX Tags
======================================*/
resource "nsxt_policy_group" "tag-based-group" {
  display_name = "tag-based-group"
  description = "Terraform-provisioned Group"
  domain       = "cgw"
  criteria {
    condition {
      key = "Tag"
      member_type = "VirtualMachine"
      operator = "EQUALS"
      value = var.TagCriteria
    }
  }
}


/*=====================================
Create DFW rules
======================================*/
resource "nsxt_policy_security_policy" "Terraform_section" {
  display_name = "Terraform_section_1"
  description = "Terraform provisioned Security Policy"
  category = "Application"
  domain = "cgw"
  locked = false
  stateful = true
  tcp_strict = false

  rule {
    display_name = "Micro-segmentation with Terraform"
    source_groups = [
      nsxt_policy_group.name-based-group.path]
    destination_groups = [
      nsxt_policy_group.name-based-group.path]
    action = "DROP"
    services = ["/infra/services/ICMP-ALL"]
    logged = true
  }
}

resource "nsxt_policy_security_policy" "Terraform_section_2" {
  display_name = "Terraform_section_1"
  description = "Terraform provisioned Security Policy"
  category = "Application"
  domain = "cgw"
  locked = false
  stateful = true
  tcp_strict = false

  rule {
    display_name = "Security Rule #1"
    source_groups = [
      nsxt_policy_group.tag-based-group.path]
    destination_groups = [
      nsxt_policy_group.ip-address-based-group.path]
    action = "DROP"
    services = ["/infra/services/ICMP-ALL"]
    logged = true
  }
  rule {
    display_name = "Security Rule #2"
    source_groups = [
      nsxt_policy_group.ip-address-based-group.path]
    destination_groups = [
      nsxt_policy_group.tag-based-group.path]
    action = "DROP"
    services = ["/infra/services/ICMP-ALL"]
    logged = true
  }
}
