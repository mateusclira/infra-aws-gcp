terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-eks-role//?version=5.3.1"
}

include {
  path = find_in_parent_folders()
}

dependency "argo-policy" {
  config_path = "../../iam-policies/argo-policy"
}

dependency "eks" {
  config_path = "../../cluster"
}

inputs = {

  create_role = true

  role_name = "argo"

  role_policy_arns = {
    "argocd:argocd-repo-policy" = dependency.argo-policy.outputs.arn
  }

  cluster_service_accounts = {
    "${dependency.eks.outputs.cluster_id}" = [
      "argocd:argocd-repo-server"
    ]
  }
}
