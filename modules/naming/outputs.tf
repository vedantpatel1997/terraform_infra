output "tokens" {
  description = "Sanitized naming tokens for organization, project, environment, and location."
  value       = local.sanitized_tokens
}

output "names" {
  description = "Map of resource keys to generated resource names."
  value       = local.names
}

output "delimited_format" {
  description = "Format string for generating additional hyphen-delimited resource names."
  value       = local.delimited_format
}

output "compact_format" {
  description = "Format string for generating compact (non-delimited) resource names."
  value       = local.compact_format
}
