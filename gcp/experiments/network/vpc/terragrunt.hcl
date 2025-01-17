terraform {
  source = "tfr:///terraform-google-modules/network/google//?version=5.2.0"
}

locals {
  computing_subnet_prefix = "computing"
}

dependency "project" {
  config_path = "../../project"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  network_name = "vpc"
  project_id   = dependency.project.outputs.project_id
  subnets      = [
    {
      subnet_name           = "${local.computing_subnet_prefix}-01"
      subnet_private_access = "true"
      subnet_ip             = "10.0.0.0/16"
      subnet_region         = "us-east1"
    },
    {
      subnet_name           = "${local.computing_subnet_prefix}-02"
      subnet_private_access = "true"
      subnet_ip             = "10.1.0.0/16"
      subnet_region         = "us-east1"
    },
    {
      subnet_name           = "${local.computing_subnet_prefix}-03"
      subnet_private_access = "true"
      subnet_ip             = "10.2.0.0/16"
      subnet_region         = "us-east1"
    }
  ]

  secondary_ranges = {
    "${local.computing_subnet_prefix}-01" = [
      {
        range_name = "gke-pods"
        ip_cidr_range = "11.0.0.0/16"
      },
      {
        range_name = "gke-services"
        ip_cidr_range = "12.0.0.0/16"
      }
    ]
  }
}
