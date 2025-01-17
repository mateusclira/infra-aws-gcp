terraform {
  source = "tfr:///terraform-google-modules/network/google//modules/firewall-rules//?version=5.2.0"
}

include {
  path = find_in_parent_folders()
}

dependency "project" {
  config_path = "../../project"
}

dependency "vpc" {
  config_path = "../../network/vpc"
}

dependency "svc-acc" {
   config_path = "../service-account"
}

dependency "cluster" {
  config_path = "../cluster"
}

inputs = {
  project_id   = dependency.project.outputs.project_id
  network_name = dependency.vpc.outputs.network_name

  rules = [{
    name                    = "allow-gke-webhook-adminssion"
    description             = "allows gke controll plane to access pods for admission controll"
    direction               = "INGRESS"
    ranges                  = [dependency.cluster.outputs.master_ipv4_cidr_block]
    priority                = null
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = [dependency.svc-acc.outputs.email]
    deny  = []
    allow = [{
      protocol = "tcp"
      ports    = ["6443"]
    }]
    log_config = {
      metadata = "EXCLUDE_ALL_METADATA"
    }
  }]
}
