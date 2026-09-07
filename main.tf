resource "databricks_storage_credential" "this" {
  name           = var.name
  isolation_mode = var.isolation_mode
  owner          = var.owner
  read_only      = var.read_only
  comment        = var.comment
  force_destroy  = var.force_destroy

  dynamic "azure_managed_identity" {
    for_each = var.azure_managed_identity == null ? [] : [var.azure_managed_identity]

    content {
      access_connector_id = azure_managed_identity.value.access_connector_id
      managed_identity_id = azure_managed_identity.value.managed_identity_id
    }
  }
}

resource "databricks_grants" "this" {
  count = length(var.grants) > 0 ? 1 : 0

  storage_credential = databricks_storage_credential.this.name

  dynamic "grant" {
    for_each = var.grants

    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}
