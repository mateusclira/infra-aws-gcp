terraform {
  source = "tfr:///terraform-google-modules/project-factory/google//?version=13.0.0"
}

include {
  path = find_in_parent_folders()
}

locals {
  env                = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  org_id             = local.env.locals.org_id
  billing_account_id = local.env.locals.billing_account_id
}

inputs = {
  name                 = "experiments"
  random_project_id    = true
  org_id               = local.org_id
  billing_account      = local.billing_account_id

  activate_apis          = [
    "compute.googleapis.com",
    "container.googleapis.com",
  ]
  default_network_tier = "STANDARD"
}
