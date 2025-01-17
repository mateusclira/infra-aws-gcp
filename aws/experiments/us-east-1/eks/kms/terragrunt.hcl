terraform {
  source = "tfr:///terraform-aws-modules/kms/aws//?version=1.1.0"
}

include {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../cluster"
}

inputs = {
    description = "experiments-kms"
}
