terraform {
  source = "tfr:///terraform-google-modules/service-accounts/google//?version=4.1.1"
}

include {
  path = find_in_parent_folders()
}

dependency "project" {
  config_path = "../../project"
}

inputs = {
  project_id    = dependency.project.outputs.project_id
  names         = ["gkegcp"]
  project_roles = [
    "${dependency.project.outputs.project_id}=>roles/compute.instanceAdmin",
    "${dependency.project.outputs.project_id}=>roles/container.clusterAdmin",
  ]
  display_name  = "GKE"
  description   = "SERVICE-ACCOUNT"
}
