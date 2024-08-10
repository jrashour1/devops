variable "clusterArn" {
  description = "cluster arn"
  type        = string
}
variable "admin_password" {
  description = "argo CD admin password"
  type        = string
  sensitive   = true
}