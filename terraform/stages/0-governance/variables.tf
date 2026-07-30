# Variables pour la configuration de la Landing Zone

variable "default_location" {
  description = "Location par défaut pour les ressources (identités managées pour les policies)"
  type        = string
  default     = "francecentral"
}

variable "enable_telemetry" {
  description = "Active ou désactive la télémétrie Microsoft"
  type        = bool
  default     = false
}

# Placement des subscriptions dans les management groups
variable "subscription_placement" {
  description = <<DESCRIPTION
Map des subscriptions à placer dans les management groups.
Exemple:
{
  "prod-sub-1" = {
    subscription_id       = "00000000-0000-0000-0000-000000000000"
    management_group_name = "alz-landing-zones-corp"
  }
}
DESCRIPTION
  type = map(object({
    subscription_id       = string
    management_group_name = string
  }))
  default = {}
}

# Modifications des policy assignments
variable "policy_assignments_to_modify" {
  description = <<DESCRIPTION
Modifications à apporter aux policy assignments de l'architecture ALZ standard.
Vous ne devez spécifier que les propriétés que vous souhaitez modifier.
DESCRIPTION
  type = map(object({
    policy_assignments = map(object({
      enforcement_mode = optional(string, null)
      identity         = optional(string, null)
      identity_ids     = optional(list(string), null)
      parameters       = optional(map(string), null)
      not_scopes       = optional(list(string), null)
      non_compliance_messages = optional(set(object({
        message                        = string
        policy_definition_reference_id = optional(string, null)
      })), null)
      resource_selectors = optional(list(object({
        name = string
        resource_selector_selectors = optional(list(object({
          kind   = string
          in     = optional(set(string), null)
          not_in = optional(set(string), null)
        })), [])
      })))
      overrides = optional(list(object({
        kind  = string
        value = string
        override_selectors = optional(list(object({
          kind   = string
          in     = optional(set(string), null)
          not_in = optional(set(string), null)
        })), [])
      })))
      creation_enabled = optional(bool, true)
    }))
  }))
  default = {}
}

# Valeurs par défaut pour les paramètres de policies
variable "policy_default_values" {
  description = <<DESCRIPTION
Valeurs par défaut pour les paramètres de policies.
Exemple:
{
  "emailSecurityContact" = jsonencode({ value = "security@example.com" })
  "logAnalyticsWorkspaceId" = jsonencode({ value = "/subscriptions/.../resourceGroups/.../providers/Microsoft.OperationalInsights/workspaces/..." })
}
DESCRIPTION
  type        = map(string)
  default     = {}
}

# Role assignments au niveau management group
variable "management_group_role_assignments" {
  description = <<DESCRIPTION
Role assignments à créer au niveau des management groups.
Exemple:
{
  "reader-assignment-1" = {
    management_group_name      = "alz"
    role_definition_id_or_name = "Reader"
    principal_id               = "00000000-0000-0000-0000-000000000000"
    description                = "Reader access for monitoring team"
  }
}
DESCRIPTION
  type = map(object({
    management_group_name                  = string
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default = {}
}


variable "default_management_group_name" {
  description = "Nom du management group par défaut pour les subscriptions sans placement spécifique"
  type        = string
  default     = "mariano-sandboxes"
}

# variable "mandatory_corporate_tags" {
#   description = "Enforced corporate tag set"
#   type = object({
#     CodeCassini            = string
#     DirectionConsommatrice = string
#     Environnement          = string
#   })
# }

variable "resource_types" {
  type = object({
    management_group              = optional(string, "Microsoft.Management/managementGroups@2023-04-01")
    management_group_settings     = optional(string, "Microsoft.Management/managementGroups/settings@2023-04-01")
    management_group_subscription = optional(string, "Microsoft.Management/managementGroups/subscriptions@2023-04-01")
    policy_assignment             = optional(string, "Microsoft.Authorization/policyAssignments@2024-04-01")
    policy_definition             = optional(string, "Microsoft.Authorization/policyDefinitions@2023-04-01")
    policy_set_definition         = optional(string, "Microsoft.Authorization/policySetDefinitions@2023-04-01")
    role_assignment               = optional(string, "Microsoft.Authorization/roleAssignments@2022-04-01")
    role_definition               = optional(string, "Microsoft.Authorization/roleDefinitions@2022-04-01")
    user_assigned_identity        = optional(string, "Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31")
  })
  default     = {}
  description = <<DESCRIPTION
A map of full AzAPI resource type strings (`<provider>/<resource>@<api-version>`) used by this module.

Override an entry to change the casing or API version of the corresponding resource type. This is useful for sovereign clouds that need different API versions (e.g. US Government), or to work around AzAPI casing inconsistencies between create and read responses (for example, providing `Microsoft.Authorization/RoleDefinitions@2022-04-01` to mitigate inconsistent-result errors from the upstream provider).

Modifying these values may produce unexpected behavior or compatibility issues which we cannot test for. Please do not raise issues against this module if you change these values.

Keys:

- `management_group` - Defaults to `Microsoft.Management/managementGroups@2023-04-01`.
- `management_group_settings` - Defaults to `Microsoft.Management/managementGroups/settings@2023-04-01`.
- `management_group_subscription` - Defaults to `Microsoft.Management/managementGroups/subscriptions@2023-04-01`.
- `policy_assignment` - Defaults to `Microsoft.Authorization/policyAssignments@2024-04-01`.
- `policy_definition` - Defaults to `Microsoft.Authorization/policyDefinitions@2023-04-01`.
- `policy_set_definition` - Defaults to `Microsoft.Authorization/policySetDefinitions@2023-04-01`.
- `role_assignment` - Defaults to `Microsoft.Authorization/roleAssignments@2022-04-01`.
- `role_definition` - Defaults to `Microsoft.Authorization/roleDefinitions@2022-04-01`.
- `user_assigned_identity` - Defaults to `Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31`.
DESCRIPTION
  nullable    = false
}