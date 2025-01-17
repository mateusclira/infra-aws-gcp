terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-policy//?version=5.3.1"
}

include {
  path = find_in_parent_folders()
}

dependency "kms" {
  config_path = "../../kms"
}

inputs = {
  name        = "argo"
  description = "Policy for ArgoCD"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Default",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "${dependency.kms.outputs.key_arn}"
    }
  ]
}
EOF
}
