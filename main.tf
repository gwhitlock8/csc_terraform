locals {
    subnetConfig = {
        for x in var.subnets => {
            subnet_name = x.subnet_name
            subnet_ip = x.subnet_ip
            subnet_region = x.subnet_region
            subnet_description = x.subnet_description
            subnet_purpose = x.subnet_purpose
        }
    }
}

locals {
    routeConfig = {
        for x in var.routes => {
            route_name = x.route_name
            dest_range = x.dest_range
            next_hop_ip = x.next_hop_ip
            route_priority = x.priority
        }
    }
}
locals {
    fwConfig = {
        for x in var.firewall_rules => {
            fw_name = x.fw_name
            fw_description = x.fw_description
            fw_priority = x.priority
            fw_direction = x.direction
            fw_destination_ranges = x.destination_ranges
            fw_source_ranges = x.source_ranges
            fw_source_tags = x.source_tags
            fw_target_tags = x.target_tags
            allow = for y in x.allow => {
                protocol = y.protocol
                ports = y.ports
            }
            deny = for z in x.deny => {
                protocol = z.protocol
                ports = z.ports
            }

        }
    }
}

locals {
    computeConfig = {
        for x in var.compute_instances => {
            compute_name = x.instance_name
            compute_machine_type = x.machine_type
            compute_tags = x.tags
            compute_image = x.image
        }
    }
}


//----------VPC-----------//

resource "google_compute_network" "vpc_network" {
  project = var.project_id
  name = var.network_name
  auto_create_subnetworks = var.auto_create_subnetworks
  mtu = var.mtu
  description = var.network_description

}

//----------SUBNETS-----------//

locals {
    subnets = flatten(local.subnetConfig)
}

resource "google_compute_subnetwork" "subnet" {
    for_each = local.subnets

    name = lookup(each.value "subnet_name","default_subnet")
    ip_cidr_range = lookup(each.value, "subnet_ip","default_subnet_cidr")
    network = google_compute_network.vpc_network.self_link
    region = var.region
    description = lookup(each.value, "subnet_description", null)
    purpose = lookup(each.value, "subnet_purpose", null)
}

//----------ROUTES-----------//

locals{
    routes = flatten(local.routeConfig)
}

resource "google_compute_route" "route" {
    for_each = local.routes

    name = lookup(each.value, "route_name", "default_route")
    dest_range = lookup(each.value, "destination_range", null)
    network = google_compute_network.vpc_network.self_link
    next_hop_ip = lookup(each.value, "next_hop_ip", null)
    priority = lookup(each.value, "route_priority",100)
}

//----------FW RULES-----------//

locals {
    fw_rules = flatten(local.fwConfig)
}

resource "google_compute_firewall" "firewall_rule" {
    for_each = local.fw_rules

    name = lookup(each.value,"fw_name","fw_rule")
    description = lookup(each.value, "fw_description", null)
    network = google_compute_network.vpc_network.self_link
    priority = lookup(each.value, "fw_priority",100)
    direction = lookup(each.value, "fw_direction", "INGRESS")
    destination_ranges = lookup(each.value, "fw_destination_ranges", null)
    source_ranges = lookup(each.value, "fw_source_ranges", null)
    source_tags = lookup(each.value, "fw_source_tags",null)
    target_tags = lookup(each.value, "fw_target_tags",null)
    
    dynamic "allow" {
        for_each = lookup(each.value, "allow", [])
        content {
            protocol = lookup(each.value.allow, "protocol",null)
            ports = lookup(each.value.allow, "ports", null)
        }
    }

    dynamic "deny" {
        for_each = lookup(each.value,"deny", [])
        content {
            protocol = lookup(each.value.deny,"protocol", null)
            ports    = lookup(each.value.deny, "ports", null)
    }
  }
}

//----------COMPUTE INSTANCES-----------//

locals {
    compute_instances = flatten(local.computeConfig)
}

resource "google_compute_instance" "default" {
    for_each = local.compute_instances

    name = lookup(each.value, "compute_name","compute_vm")
    machine_type = lookup(each.value, "compute_machine_type", "n2-standard-4")
    tags = lookup(each.value,"tags", [])

    boot_disk {
        initialize_params {
            image = lookup(each.value, "compute_image","ubuntu-pro-2004-lts")
        }
    }

    network_interface {
        network = google_compute_network.vpc_network.self_link
    }
}





