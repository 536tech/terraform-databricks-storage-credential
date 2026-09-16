variable "name" {
  description = "Storage credential name."
  type        = string
  nullable    = false

  validation {
    condition     = try(length(trimspace(var.name)) > 0, false)
    error_message = "name must not be empty or blank."
  }
}

variable "isolation_mode" {
  description = "Isolation mode: ISOLATION_MODE_OPEN or ISOLATION_MODE_ISOLATED."
  type        = string

  validation {
    condition     = var.isolation_mode == null ? true : contains(["ISOLATION_MODE_OPEN", "ISOLATION_MODE_ISOLATED"], var.isolation_mode)
    error_message = "isolation_mode must be ISOLATION_MODE_OPEN or ISOLATION_MODE_ISOLATED."
  }
}

variable "owner" {
  description = "Storage credential owner. A user, group, or service principal."
  type        = string

  validation {
    condition     = var.owner == null ? true : try(length(trimspace(var.owner)) > 0, false)
    error_message = "owner must not be empty or blank."
  }
}

variable "read_only" {
  description = "Limit the credential to read access."
  type        = bool
}

variable "comment" {
  description = "Storage credential description."
  type        = string
  default     = null
}

variable "azure_managed_identity" {
  description = "Azure access connector that backs the credential."

  type = object({
    access_connector_id = string
    managed_identity_id = optional(string)
  })

  default = null
}

variable "grants" {
  description = "Direct credential grants. The list supports computed application IDs."
  type = list(object({
    principal  = string
    privileges = list(string)
  }))
  default  = []
  nullable = false

  validation {
    condition = try(alltrue([for grant in var.grants :
      length(trimspace(grant.principal)) > 0 && length(grant.privileges) > 0 &&
      alltrue([for privilege in grant.privileges : length(trimspace(privilege)) > 0])
    ]) && length(distinct([for grant in var.grants : grant.principal])) == length(var.grants), false)
    error_message = "Each grant needs a unique nonblank principal and at least one nonblank privilege."
  }
}

variable "force_destroy" {
  description = "Allow Terraform to delete the credential while external locations still use it."
  type        = bool
  default     = false
}
