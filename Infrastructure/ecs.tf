resource "aws_ecs_cluster" "main" {
    name = "cb-cluster"
}

# data "template_file" "cb_app" {
#     template = file("./templates/ecs/cb_app.json.tpl")

#     vars = {
#         app_image      = var.app_image
#         app_port       = var.app_port
#         fargate_cpu    = var.fargate_cpu
#         fargate_memory = var.fargate_memory
#         aws_region     = var.aws_region
#     }
# }

# resource "aws_ecs_task_definition" "front_end_td" {
#     family                   = "cb-app-task"
#     execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
#     network_mode             = "awsvpc"
#     requires_compatibilities = ["FARGATE"]
#     cpu                      = var.fargate_cpu
#     memory                   = var.fargate_memory
#     container_definitions    = data.template_file.cb_app.rendered
# }

resource "aws_ecs_service" "frontend_svc" {
    name            = "frontendsvc"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.frontend.arn
    desired_count   = var.app_count
    launch_type     = "FARGATE"

    network_configuration {
        security_groups  = [aws_security_group.servicesg.id]
        subnets          = aws_subnet.private.*.id
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = aws_alb_target_group.app.id # changes needed here
        container_name   = "frontendContainer"
        container_port   = var.app_port
    }

    depends_on = [aws_alb_listener.front_end]
}


//============================================================================================//
resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontendtd"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "frontendContainer",
    "image": "464672143257.dkr.ecr.eu-north-1.amazonaws.com/devops-frontend",
    "cpu": 512,
    "memory": 1024,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 3000,
        "protocol": "tcp"
      }
    ]
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
// IAM roles
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRolev2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


//========================================================================================================================================
resource "aws_ecs_service" "backend_svc" {
    name            = "backendsvc"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.backend.arn
    desired_count   = var.app_count
    launch_type     = "FARGATE"

    network_configuration {
        security_groups  = [aws_security_group.servicesg.id]
        subnets          = aws_subnet.private.*.id
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = aws_alb_target_group.backend.id # changes needed here
        container_name   = "backendContainer"
        container_port   = var.backend_port
    }

    depends_on = [aws_alb_listener.front_end]
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "backendtd"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "backendContainer",
    "image": "464672143257.dkr.ecr.eu-north-1.amazonaws.com/devops-backend",
    "cpu": 512,
    "memory": 1024,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8000,
        "protocol": "tcp"
      }
    ]
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}