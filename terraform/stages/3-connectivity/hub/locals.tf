locals {
  # ── Subnet CIDRs carved from hub_address_space ───────────────────────────
  # GatewaySubnet and AzureBastionSubnet are reserved but not used in MVP.
  snet_gateway           = cidrsubnet(var.hub_address_space, 11, 0) # /27 — Azure min for GatewaySubnet
  snet_bastion           = cidrsubnet(var.hub_address_space, 10, 1) # /26 — Azure min for AzureBastionSubnet
  snet_shared            = cidrsubnet(var.hub_address_space, 8, 2)  # /24 — shared services
  snet_private_endpoints = cidrsubnet(var.hub_address_space, 8, 3)  # /24 — all platform private endpoints

  # ── NSG rules — snet-shared ───────────────────────────────────────────────
  nsg_rules_shared = {
    allow-inbound-vnet = {
      name                       = "allow-inbound-vnet"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
    allow-inbound-azurelb = {
      name                       = "allow-inbound-azurelb"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
    }
    deny-inbound-internet = {
      name                       = "deny-inbound-internet"
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }
    allow-outbound-keyvault = {
      name                       = "allow-outbound-keyvault"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureKeyVault"
    }
    allow-outbound-monitor = {
      name                       = "allow-outbound-monitor"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureMonitor"
    }
    allow-outbound-vnet = {
      name                       = "allow-outbound-vnet"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
    deny-outbound-internet = {
      name                       = "deny-outbound-internet"
      priority                   = 4000
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }

  # ── NSG rules — snet-private-endpoints ───────────────────────────────────
  nsg_rules_private_endpoints = {
    allow-inbound-vnet = {
      name                       = "allow-inbound-vnet"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
    deny-inbound-internet = {
      name                       = "deny-inbound-internet"
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }
    allow-outbound-vnet = {
      name                       = "allow-outbound-vnet"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
    deny-outbound-internet = {
      name                       = "deny-outbound-internet"
      priority                   = 4000
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }
}
