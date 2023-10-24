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
    routeConfig = {
        for x in var.routes => {
            route_name = x.route_name
            dest_range = x.dest_range
            next_hop_ip = x.next_hop_ip
            priority = x.priority
        }
    }
    fwConfig = {
        for x in var.firewall_rules => {
            name = x.fw_name
            description = x.fw_description
            priority = x.priority
            direction = x.direction
            destination_ranges = x.destination_ranges
            source_ranges = x.source_ranges
            source_tags = x.source_tags
            target_tags = x.target_tags
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
    computeConfig = {
        for x in var.compute_instances => {
            name = x.instance_name
            machine_type = x.machine_type
            tags = [x.tags]
            image = x.image
        }
    }
}

locals {
    subnets = flatten(local.subnetConfig)
    routes = flatten(local.routeConfig)
    fw_rules = flatten(local.fwConfig)
    compute_instances = flatten(local.computeConfig)

}


resource "google_compute_network" "vpc_network" {
  project = var.project_id
  name = var.network_name
  auto_create_subnetworks = var.auto_create_subnetworks
  mtu = var.mtu
  description = var.network_description

}

resource "google_compute_subnetwork" "subnet" {
    for_each = local.subnets

    name = each.value.subnet_name
    ip_cidr_range = each.value.subnet_ip
    network = google_compute_network.vpc_network.self_link
    region = each.value.subnet_region
    description = each.value.subnet_description
    purpose = each.value.subnet_purpose
}

resource "google_compute_route" "route" {
    for_each = local.routes

    name = each.value.route_name
    dest_range = lookup(each.value, "destination_range", null)
    network = google_compute_network.vpc_network.self_link
    next_hop_ip = lookup(each.value, "next_hop_ip", null)
    priority = each.value.priority
}

resource "google_compute_firewall" "firewall_rule" {
    for_each = local.fw_rules

    name = each.value.name
    description = each.value.description
    network = google_compute_network.vpc_network.self_link
    priority = each.value.priority
    direction = each.value.direction
    destination_ranges = lookup(each.value, "destination_ranges", null)
    source_ranges = lookup(each.value, "source_ranges", null)
    source_tags = each.value.source_tags
    target_tags = each.value.target_tags
    
    dynamic "allow" {
        for_each = lookup(each.value, "allow", [])
        content {
            protocol = allow.value.protocol
            ports = lookup(allow.value, "ports", null)
        }
    }

    dynamic "deny" {
        for_each = lookup(each.value,"deny", [])
        content {
            protocol = deny.value.protocol
            ports    = lookup(deny.value, "ports", null)
    }
  }
}

resource "google_compute_instance" "default" {
    for_each = local.compute_instances

    name = each.value.name
    machine_type = each.value.machine_type
    tags = lookup(each.value,"tags", [])

    boot_disk {
        initialize_params {
            image = each.value.image
        }
    }

    network_interface {
        network = google_compute_network.vpc_network.self_link
    }
}





