resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  version = var.kubernetes_version
  timeouts {
    create = "60m"
    delete = "60m"
  }
}
