mock_provider "databricks" {}

variables {
  azure_managed_identity = {
    access_connector_id = "/subscriptions/fixture/resourceGroups/fixture/providers/Microsoft.Databricks/accessConnectors/fixture"
  }
  grants = [{
    principal  = "fixture-group"
    privileges = ["READ_FILES"]
  }]
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  name           = "fixture-credential"
  owner          = "fixture-owner"
  read_only      = false
}

run "grant_uses_stable_name" {
  command = plan

  assert {
    condition     = databricks_grants.this[0].storage_credential == var.name
    error_message = "The grant import target must use the known storage credential name."
  }
}
