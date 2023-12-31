variable "project" {
  description = "The ID of the project where this VPC will be created"
  type        = string
  default = "arvest-demo"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}


//-------------NETWORK-----------------//

variable "network_name" {
  description = "The name of the network being created"
  type        = string
  default = "test"
}

variable "network_description" {
  type        = string
  description = "An optional description of this resource. The resource must be recreated to modify this field."
  default     = "for testing"
}

variable "auto_create_subnetworks" {
  type        = bool
  description = "When set to true, the network is created in 'auto subnet mode' and it will create a subnet for each region automatically across the 10.128.0.0/9 address range. When set to false, the network is created in 'custom subnet mode' so the user can explicitly connect subnetwork resources."
  default     = false
}


variable "mtu" {
  type        = number
  description = "The network MTU (If set to 0, meaning MTU is unset - defaults to '1460'). Recommended values: 1460 (default for historic reasons), 1500 (Internet default), or 8896 (for Jumbo packets). Allowed are all values in the range 1300 to 8896, inclusively."
  default     = 0
}

//--------------SUBNETS----------------//

variable "subnets" {
  type = list(object({
    subnet_name                      = string
    subnet_ip                        = string
    subnet_region                    = string
    subnet_description               = optional(string)
    subnet_purpose                   = optional(string)

  }))
  description = "The list of subnets being created"
  default = [{
    subnet_name = "test"
    subnet_ip = "10.0.0.0/24"
    subnet_region = "us-central1"
    subnet_description = ""
    subnet_purpose = ""
  }]
}

//--------------ROUTES----------------//

variable "routes" {
    type = list(object({
        route_name = string
        dest_range = string
        route_network = string
        next_hop_ip = string
        priority = number
    }))

    default = [{
      route_name = "test"
      dest_range = "10.10.0.0/24"
      route_network = "google_cloud_network.vpc_network.self_link"
      next_hop_ip = "10.0.0.96"
      priority = 12
    }]
}


//--------------FW RULES----------------//

variable "firewall_rules" {
    description = "List of ingress rules. This will be ignored if variable 'rules' is non-empty"
    default     = []
    type = list(object({
        fw_name = string
        fw_description = optional(string, null)
        priority = optional(number, null)
        direction = optional(string,"INGRESS")
        destination_ranges = optional(list(string), [])
        source_ranges = optional(list(string), [])
        source_tags = optional(list(string))
        target_tags = optional(list(string))

        allow = optional(list(object({
            protocol = string
            ports = optional(list(string))
        })), [])
        deny = optional(list(object({
            protocol = string
            ports    = optional(list(string))
        })), [])
    }))

}

//--------------COMPUTE INSTANCE----------------//

variable "compute_instances" {
    type = list(object({
        compute_name = string
        machine_type = string
        instance_zone = string
        tags = optional(list(string))
        image = string
    }))

    default = [{
      compute_name = "test"
      machine_type = "n2-standard-4"
      instance_zone = "us-central1-a"
      tags = ["test","another_test"]
      image = "ubuntu-2004-focal-arm64-v20231023"
    }]
}
