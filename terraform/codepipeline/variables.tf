variable "tags_as_map" {
  description = "A map of tags and values in the same format as other resources accept."
  type        = map(string)
}

variable "github_organization" {
  description = "gihub organization name"
  type        = string
}

variable "github_repo_name" {
  description = "gihub repo name"
  type        = string
}

variable "github_secrets_arn" {
  description = "aws secrets arn"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ecs cluster to deploy to"
  type        = string
}