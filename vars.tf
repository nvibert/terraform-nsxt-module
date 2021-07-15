variable "host" {
  description = "VMC NSX-T REVERSE PROXY URL"
}

variable "vmc_token" {
  description = "VMC Token"
}

variable "Subnet" {
  default = "10.10.10.0/24"
}

variable "TransportZone" {
  default = "vmc-overlay-tz"
}

variable "SubnetGateway" {
  default = "10.10.10.1/24"
}

variable "SubnetRange" {
  default = "10.10.10.100-10.10.10.200"
}

variable "NameCriteria" {
  default = "vmname"
}

variable "TagCriteria" {
  default = "tagValue"
}
