### ECS
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
  tags = var.tags_as_map
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${lookup(var.tags_as_map, "application")}-ecs"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {
  family                   = lookup(var.tags_as_map, "application")
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  tags = var.tags_as_map

  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = <<DEFINITION
[
  {
    "cpu": 256,
    "image": "421654392560.dkr.ecr.us-east-1.amazonaws.com/react-cicd",
    "memory": 512,
    "name": "web",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "essential": true
  }
]
DEFINITION
}

### Security

# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {
  name        = "${lookup(var.tags_as_map, "application")}-ecs-alb"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id
  tags = var.tags_as_map
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "${lookup(var.tags_as_map, "application")}-ecs-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id
  tags = var.tags_as_map
  ingress {
    protocol        = "tcp"
    from_port       = "80"
    to_port         = "80"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}