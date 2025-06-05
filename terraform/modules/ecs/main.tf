resource "aws_ecs_cluster" "this" {
  name = "myapp-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "myapp-task"
  container_definitions    = jsonencode([
    {
      name      = "app"
      image     = "${var.ecr_url}:${var.image_tag}"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  cpu                      = "256"
  memory                   = "512"
}

resource "aws_ecs_service" "app" {
  name            = "myapp-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.security_group]
    assign_public_ip = true
  }
}
