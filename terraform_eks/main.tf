module "eks" {
  source = "./module/eks"

  cluster_name      = var.cluster_name
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  node_group_name   = var.node_group_name
  node_instance_type = var.node_instance_type
  desired_size      = var.desired_size
  min_size          = var.min_size
  max_size          = var.max_size
}
