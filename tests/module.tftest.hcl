mock_provider "databricks" {}

variables {

  name           = "lake_cred"
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  owner          = "data-platform"
  read_only      = false

  azure_managed_identity = {
    access_connector_id = "/subscriptions/.../accessConnectors/lake-ac"
  }

  grants = [{
    principal  = "data-platform-admins"
    privileges = ["ALL_PRIVILEGES"]
  }]
}

run "documented_example" {
  command = apply

  assert {
    condition     = databricks_storage_credential.this.name == var.name
    error_message = "The resource must preserve its configured name."
  }

  assert {
    condition     = length(databricks_grants.this) == 1
    error_message = "Configured access must have stable resource addresses."
  }
}

run "without_access" {
  command = plan

  variables {
    grants = []
  }

  assert {
    condition     = length(databricks_grants.this) == 0
    error_message = "Empty access must omit the access resources."
  }
}

run "reject_blank_name" {
  command = plan
  variables {
    name = "  "
  }
  expect_failures = [var.name]
}

run "reject_blank_principal" {
  command = plan
  variables {
    grants = [{ principal = " ", privileges = ["SELECT"] }]
  }
  expect_failures = [var.grants]
}

run "reject_empty_privileges" {
  command = plan
  variables {
    grants = [{ principal = "readers", privileges = [] }]
  }
  expect_failures = [var.grants]
}

run "reject_duplicate_principal" {
  command = plan
  variables {
    grants = [{ principal = "readers", privileges = ["SELECT"] }, { principal = "readers", privileges = ["MODIFY"] }]
  }
  expect_failures = [var.grants]
}

run "reject_isolation_mode" {
  command = plan
  variables {
    isolation_mode = "INVALID"
  }
  expect_failures = [var.isolation_mode]
}
