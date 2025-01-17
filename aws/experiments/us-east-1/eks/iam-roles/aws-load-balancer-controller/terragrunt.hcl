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
  role_name                               = "aws-load-balancer-controller"
  clusterName                             = "experiments"
  attach_load_balancer_controller_policy  = true

  oidc_providers = {
    ex = {
      provider_arn               = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = [
        "addons:aws-load-balancer-controller",
      ]
    }
  }
}
