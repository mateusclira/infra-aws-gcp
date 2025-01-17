locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket    = "company-terraform-backend"
    prefix    = path_relative_to_include()
    project   = "company-root"
    location  = "US"
  }
}
