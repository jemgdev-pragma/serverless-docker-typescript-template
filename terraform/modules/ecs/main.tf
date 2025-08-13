resource "aws_ecs_cluster" "cluster" {
  name = "template-cluster-${var.stage}"
}

resource "aws_iam_role" "task_execution_role" {
  name = "template-task-${var.stage}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "template-task-${var.stage}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "template-container"
      image = "${var.repo_url}:latest"
      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.expose_port
        }
      ]
      environment = [
        { name = "PORT", value = tostring(var.port) }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "template-ecs-service-${var.stage}"
  cluster         = aws_ecs_cluster.cluster.id
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.task.arn

  network_configuration {
    subnets         = [var.subnet_id]
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }
}

output "service_name" {
  value = aws_ecs_service.service.name
}
