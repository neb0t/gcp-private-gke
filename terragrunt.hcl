### Project identification
locals {
  project_name   = "driven-edition-333218"
  project_domain = "earn-something"
  gcs_region     = "eu"

  tfstate_region = local.gcs_region
  tfstate_bucket = lower("tfstate-${local.gcs_region}-${local.project_domain}")
}

### Automatic input variables
inputs = {
  # Must be overriden in environments
  project_env    = ""

  # Same for all environments
  project_name   = local.project_name

  # State parameters
  tfstate_region = local.tfstate_region
  tfstate_bucket = local.tfstate_bucket
}

### Terraform configuration
terraform {
  extra_arguments "custom_vars" {
    commands = get_terraform_commands_that_need_vars()

    required_var_files = []

    # Ensure that terraform.tfvars is loaded *after* common.tfvars
    optional_var_files = [
      "${get_terragrunt_dir()}/terraform.tfvars",
    ]
  }
}

### Remote state gcs configuration
remote_state {
  backend = "gcs"
  config = {
    location = local.tfstate_region
    project = local.project_name
    bucket = local.tfstate_bucket
    prefix = "${path_relative_to_include()}/terraform"
  }
}
