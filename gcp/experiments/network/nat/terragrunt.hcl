terraform {
  source = "tfr:///terraform-google-modules/cloud-nat/google//?version=2.2.1"
}

locals {
  computing_subnet_prefix = "computing"
}

dependency "project" {
  config_path = "../../project"
}
dependency "vpc" {
    config_path = "../vpc"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name                               = "nat"
  project_id                         = dependency.project.outputs.project_id
  create_router                      = true
  router                             = "router"
  region                             = "us-east1"
  network                            = dependency.vpc.outputs.network_name
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetworks = [ for subnet in dependency.vpc.outputs.subnets_names :
    {
      name                    = subnet,
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
      secondary_ip_range_names = []
    }
  ]
}
