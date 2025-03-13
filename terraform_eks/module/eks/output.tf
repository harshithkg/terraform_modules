output "cluster_id" {
  description = "EKS Cluster ID"
  value       = aws_eks_cluster.eks.id
}

output "cluster_endpoint" {
  description = "EKS Cluster API Endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "node_group_arn" {
  description = "ARN of the worker node group"
  value       = aws_eks_node_group.eks_nodes.arn
}
