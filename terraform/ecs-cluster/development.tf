resource "aws_ecs_service" "development" {
  name            = "${lookup(var.tags_as_map, "application")}-development"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = "1"
  launch_type     = "FARGATE"
  tags = var.tags_as_map
  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = var.public_vpc_subnet_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.development.id
    container_name   = "web"
    container_port   = "80"
  }

  depends_on = [
    aws_alb_listener.development_front_end
  ]
}

### ALB

resource "aws_alb" "development" {
  name            = "${lookup(var.tags_as_map, "application")}-development"
  subnets         = var.public_vpc_subnet_ids
  security_groups = [aws_security_group.lb.id]
  tags = var.tags_as_map
}

resource "aws_alb_target_group" "development" {
  name        = "${lookup(var.tags_as_map, "application")}-development"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags = var.tags_as_map
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "development_front_end" {
  load_balancer_arn = aws_alb.development.id
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    target_group_arn = aws_alb_target_group.development.id
    type             = "forward"
  }
}

output "Developmnet_LB_DNS" {
  description = "The DNS name of the development ALB"
  value       = aws_alb.development.dns_name
}

output "Developmnet_ECS_Service_Name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.development.name
}