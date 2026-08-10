locals {
  request = yamldecode(file("${path.module}/spokes/${var.spoke_file}"))

  spoke_name    = local.request.spoke_name
  address_space = local.request.address_space

  subnets  = lookup(local.request, "subnets", {})
  location = lookup(local.request, "location", var.default_location)

  private_dns_zone_link_enabled = lookup(local.request, "private_dns_zone_link_enabled", false)
  # Only link DNS zones when both the request enables it and the hub exported zone IDs.
  private_dns_zone_ids = local.private_dns_zone_link_enabled ? var.private_dns_zone_ids : {}

  base_tags = {
    managed-by = "terraform"
    stage      = "spoke-vending"
  }
  spoke_tags = lookup(local.request, "tags", {})
  tags       = merge(local.base_tags, local.spoke_tags)
}
