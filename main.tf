locals {
    subnets = {
        for subnet in var.subnets:"subnet" => {
            subnet_name = subnet.subnet_name,
            subnet_ip = subnet.subnet_ip,
            subnet_region = subnet.subnet_region,
            subnet_description = subnet.subnet_description,
            subnet_purpose = subnet.subnet_purpose,
        }
    }
}

locals {
    routes = {
        for route in var.routes:"route" => {
            route_name = route.route_name,
            dest_range = route.dest_range,
            next_hop_ip = route.next_hop_ip,
            route_priority = route.priority,
        }
    }
}
locals {
    fw_rules = {
        for fw in var.firewall_rules:fw => {
            fw_name = fw.fw_name,
            fw_description = fw.fw_description,
            fw_priority = fw.priority,
            fw_direction = fw.direction,
            fw_destination_ranges = fw.destination_ranges,
            fw_source_ranges = fw.source_ranges,
            fw_source_tags = fw.source_tags,
            fw_target_tags = fw.target_tags,
            allow = {for allow in fw.allow:allow => {
                protocol = allow.protocol,
                ports = allow.ports
            }},
            deny = {for deny in fw.deny:deny => {
                protocol = deny.protocol,
                ports = deny.ports
            }}
        }
    }
}

locals {
    compute_instances = {
        for compute in var.compute_instances:"compute" => {
            compute_name = compute.compute_name,
            compute_machine_type = compute.machine_type,
            compute_tags = compute.tags,
            compute_image = compute.image,
        }
    }
}

provider "google" {
    credentials = file("./credentials.json")
    project = "${var.project}"
    region = "${var.region}"
    zone = "${var.zone}"
}


//----------VPC-----------//

resource "google_compute_network" "vpc_network" {
  project = var.project
  name = var.network_name
  auto_create_subnetworks = var.auto_create_subnetworks
  mtu = var.mtu
  description = var.network_description

}

//----------SUBNETS-----------//


resource "google_compute_subnetwork" "subnet" {
    for_each = local.subnets

    name = lookup(each.value,"subnet_name","default_subnet")
    ip_cidr_range = lookup(each.value, "subnet_ip","default_subnet_cidr")
    network = google_compute_network.vpc_network.self_link
    region = var.region
    description = lookup(each.value, "subnet_description", null)
    purpose = lookup(each.value, "subnet_purpose", null)
}

//----------ROUTES-----------//


resource "google_compute_route" "route" {
    for_each = local.routes

    name = lookup(each.value, "route_name", "default_route")
    dest_range = lookup(each.value, "dest_range", null)
    network = google_compute_network.vpc_network.self_link
    next_hop_ip = lookup(each.value, "next_hop_ip", null)
    priority = lookup(each.value, "route_priority",100)
}

//----------FW RULES-----------//


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





