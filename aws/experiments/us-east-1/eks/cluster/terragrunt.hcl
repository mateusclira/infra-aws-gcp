terraform {
  source = "tfr:///terraform-aws-modules/eks/aws//?version=18.29.0"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../../vpc"
}

locals {
  region     = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region = local.region.locals.region
}

generate "k8s-provider" {
  path      = "k8s-provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    provider "kubernetes" {
      host                   = aws_eks_cluster.this[0].endpoint
      cluster_ca_certificate = base64decode(aws_eks_cluster.this[0].certificate_authority.0.data)
      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this[0].id]
      }
      config_path = "~/.kube/config"
    }
  EOF
}

inputs = {
  cluster_name = "experiments"

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  eks_managed_node_groups = {
    "node-pool-02" = {
      min_size                   = 3
      max_size                   = 10
      desired_size               = 3

      enable_bootstrap_user_data = true

      ami_id                     = "ami-whatever image we will use"

      instance_types             = ["t3.micro"]
      capacity_type              = "SPOT"

      enable_monitoring          = false

      update_config = {
        max_unavailable_percentage = 50
      }
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      role_arn = "arn:aws:iam::account-id of aws account:role/create a role to put here -> Like AWS Admin"
      username = "create a role to put here -> Like AWS Admin:{{SessionName}}"
      groups   = ["system:masters"]
    }
  ]

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    },
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    },
    egress_all = {
      description      = "internet egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    },
    efs_ingress = {
      description = "Allow efs ingress communication"
      protocol    = "TCP"
      from_port   = 2049
      to_port     = 2049
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    efs_egress = {
      description = "Allow efs egress communication"
      protocol    = "TCP"
      from_port   = 2049
      to_port     = 2049
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }
}
