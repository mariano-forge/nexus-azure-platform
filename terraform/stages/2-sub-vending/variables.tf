variable "subscription_name" {
  type        = string
  description = "YAML filename (without extension) in requests/ to deploy. Set by the CI pipeline via -var='subscription_name=corp-prod'."
}

variable "default_location" {
  type        = string
  description = "Default Azure region. Overridable per request via the YAML 'location' field."
  default     = "francecentral"
}

variable "default_billing_scope" {
  type        = string
  description = <<-DESCRIPTION
    Default billing scope used to create subscriptions. Overridable per request via the YAML 'subscription_billing_scope' field.

    Formats:
      EA  : /providers/Microsoft.Billing/billingAccounts/{id}/enrollmentAccounts/{id}
      MCA : /providers/Microsoft.Billing/billingAccounts/{id}/billingProfiles/{id}/invoiceSections/{id}
      MPA : /providers/Microsoft.Billing/billingAccounts/{id}/customers/{id}
  DESCRIPTION
  default     = null
}

variable "enable_telemetry" {
  type        = bool
  default     = false
  description = "Enable or disable AVM telemetry. See https://aka.ms/avm/telemetryinfo."
}
