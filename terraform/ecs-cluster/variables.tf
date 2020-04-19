variable "tags_as_map" {
  description = "A map of tags and values in the same format as other resources accept."
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_vpc_subnet_ids" {
  description = "Public Subnets"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "ecs cluster name"
  type        = string
}