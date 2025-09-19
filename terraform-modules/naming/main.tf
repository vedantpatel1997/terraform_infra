locals {
  raw_tokens = {
    org         = var.org_code
    project     = var.project_code
    environment = var.environment
    location    = var.location
  }

  normalized_tokens = {
    for key, value in local.raw_tokens :
    key => lower(trimspace(value))
  }

  sanitized_tokens = {
    for key, value in local.normalized_tokens :
    key => trim(
      replace(
        replace(
          replace(replace(value, "_", "-"), " ", "-"),
          "[^a-z0-9-]",
          "-",
        ),
        "-{2,}",
        "-",
      ),
      "-",
    )
  }

  default_max_length = {
    generic        = 80
    resource_group = 90
    storage        = 24
    acr            = 50
    key_vault      = 24
  }

  sanitized_resource_definitions = {
    for key, definition in var.resource_definitions :
    key => {
      purpose = trim(
        replace(
          replace(
            replace(replace(lower(trimspace(definition.purpose)), "_", "-"), " ", "-"),
            "[^a-z0-9-]",
            "-",
          ),
          "-{2,}",
          "-",
        ),
        "-",
      )
      resource_type = coalesce(lookup(definition, "resource_type", null), "generic")
      max_length = coalesce(
        lookup(definition, "max_length", null),
        lookup(
          local.default_max_length,
          coalesce(lookup(definition, "resource_type", null), "generic"),
          80,
        ),
      )
    }
  }

  prefix_tokens = [
    local.sanitized_tokens.org,
    local.sanitized_tokens.project,
  ]

  suffix_tokens = [
    local.sanitized_tokens.environment,
    local.sanitized_tokens.location,
  ]

  resource_tokens = {
    for key, definition in local.sanitized_resource_definitions :
    key => concat(local.prefix_tokens, [definition.purpose], local.suffix_tokens)
  }

  joiner_overrides = {
    storage = ""
    acr     = ""
  }

  resource_joined_names = {
    for key, definition in local.sanitized_resource_definitions :
    key => join(
      lookup(local.joiner_overrides, definition.resource_type, "-"),
      local.resource_tokens[key],
    )
  }

  names = {
    for key, definition in local.sanitized_resource_definitions :
    key => substr(
      local.resource_joined_names[key],
      0,
      min(length(local.resource_joined_names[key]), definition.max_length),
    )
  }

  delimited_format = format(
    "%s-%s-%%s-%s-%s",
    local.sanitized_tokens.org,
    local.sanitized_tokens.project,
    local.sanitized_tokens.environment,
    local.sanitized_tokens.location,
  )

  compact_format = format(
    "%s%s%%s%s%s",
    local.sanitized_tokens.org,
    local.sanitized_tokens.project,
    local.sanitized_tokens.environment,
    local.sanitized_tokens.location,
  )
}
