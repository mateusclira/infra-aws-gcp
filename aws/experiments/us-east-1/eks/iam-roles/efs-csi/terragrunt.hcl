terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks?version=5.3.0"
}

include {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../../cluster"
}

inputs = {
  role_name                     = "efs-csi"
  attach_efs_csi_policy         = true

  oidc_providers = {
    ex = {
      provider_arn               = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = [
        "addons:efs-csi-controller-sa",
        "addons:efs-csi-node-sa",
      ]
    }
  }
}
