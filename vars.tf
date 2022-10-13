variable "vpc_name" {}
variable "cidr" {}
variable "az" {
  type = list(any)
}
variable "public_subnets" {
  type = list(any)
}
variable "enable_nat_gateway" {
  type = bool
}
variable "single_nat_gateway" {
  type = bool
}
variable "private_subnets" {
  type = list(any)
}
variable "alb_name" {}
variable "ecs_cluster_name" {}