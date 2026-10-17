resource "aws_eks_cluster" "main" {
  name     = "voting-app"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = data.aws_subnets.default.ids
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "voting-app-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = data.aws_subnets.default.ids
  instance_types  = ["m7i-flex.large"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only,
  ]
}