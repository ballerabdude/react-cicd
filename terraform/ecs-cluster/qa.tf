resource "aws_ecs_service" "qa" {
  name            = "${lookup(var.tags_as_map, "application")}-qa"
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
    target_group_arn = aws_alb_target_group.qa.id
    container_name   = "web"
    container_port   = "80"
  }

  depends_on = [
    aws_alb_listener.qa_front_end
  ]
}

### ALB

resource "aws_alb" "qa" {
  name            = "${lookup(var.tags_as_map, "application")}-qa"
  subnets         = var.public_vpc_subnet_ids
  security_groups = [aws_security_group.lb.id]
  tags = var.tags_as_map
}

resource "aws_alb_target_group" "qa" {
  name        = "${lookup(var.tags_as_map, "application")}-qa"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags = var.tags_as_map
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "qa_front_end" {
  load_balancer_arn = aws_alb.qa.id
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    target_group_arn = aws_alb_target_group.qa.id
    type             = "forward"
  }
}

output "QA_LB_DNS" {
  description = "The DNS name of the qa ALB"
  value       = aws_alb.qa.dns_name
}

output "QA_ECS_Service_Name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.qa.name
}