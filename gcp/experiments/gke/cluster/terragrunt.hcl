terraform {
  source = "tfr:///terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster//?version=23.0.0"
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

inputs = {
  name = "gke-cluster"
  region = "us-east1"
  subnetwork = element(dependency.vpc.outputs.subnets_names, 0)
  remove_default_node_pool = true
  ip_range_services = element(element(dependency.vpc.outputs.subnets_secondary_ranges, 0), 0)["range_name"]  ##The secondary ip range to use for services
  ip_range_pods     = element(element(dependency.vpc.outputs.subnets_secondary_ranges, 0), 1)["range_name"]  ##The secondary ip range to use for pods
  network  = dependency.vpc.outputs.network_name
  project_id = dependency.project.outputs.project_id

  zones = [
    "us-east1-b",
    "us-east1-c",
    "us-east1-d"
  ]
  node_pools = [
    {
      name                      = "node-pool"                                       
      machine_type              = "e2-standard-2"                                   
      node_locations            = "us-east1-b,us-east1-c,us-east1-d"                     
      min_count                 = 1                                                
      max_count                 = 5                                                 
      local_ssd_count           = 0                                                 
      spot                      = true
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = true
      enable_gvnic              = false
      auto_repair               = true
      auto_upgrade              = true
      service_account           = dependency.svc-acc.outputs.email
      preemptible               = false
      initial_node_count        = 1
    },
  ]
}
