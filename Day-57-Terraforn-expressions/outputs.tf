output "environment_count" {
  description = "Count environments using length()"
  value       = length(var.environments)
}

output "uppercase_env_names" {
  description = "For expression returning uppercase environment names"
  value       = [for env in keys(var.environments) : upper(env)]
}

output "lowercase_env_descriptions" {
  description = "For expression returning lowercase descriptions"
  value       = [for desc in values(var.environments) : lower(desc)]
}

output "joined_environments" {
  description = "Combine environment names using join()"
  value       = join(", ", keys(var.environments))
}

output "environment_tiers_conditional" {
  description = "Conditional expression identifying production vs non-production"
  value = {
    for k, v in var.environments :
    k => k == "prod" ? "Production Tier (Critical)" : "Non-Production Tier"
  }
}

output "lookup_test_env" {
  description = "Retrieve map value with a default using lookup()"
  value       = lookup(var.environments, "test", "Default: Test environment not present")
}
