resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${lookup(var.tags_as_map, "application")}-codepipeline"
  acl    = "private"
  force_destroy = true
  tags = var.tags_as_map
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${lookup(var.tags_as_map, "application")}-codepipeline_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "ecs:DescribeServices",
        "ecs:CreateTaskSet",
        "ecs:UpdateServicePrimaryTaskSet",
        "ecs:DeleteTaskSet",
        "ecs:ListClusters",
        "ecs:ListServices",
        "ecs:*",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret_version" "github_secrets" {
  secret_id = var.github_secrets_arn
}

# A shared secret between GitHub and AWS
locals {
  github_personal_token = data.aws_secretsmanager_secret_version.github_secrets.secret_string
}