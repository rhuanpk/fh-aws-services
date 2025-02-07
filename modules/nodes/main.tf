resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = "node-ftc4"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  scaling_config {
    desired_size = 6
    max_size     = 10
    min_size     = 4
  }
  instance_types = ["t2.medium"]
}
