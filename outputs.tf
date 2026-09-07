output "id" {
  description = "Storage credential id."
  value       = databricks_storage_credential.this.id
}

output "name" {
  description = "Storage credential name."
  value       = databricks_storage_credential.this.name
}
