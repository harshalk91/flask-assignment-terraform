# Add flask security group allowing port 5000 from load balancer
resource "aws_security_group" "ecs_security_group" {
  name   = "${var.ecs_cluster_name}-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port       = 5000
    protocol        = "tcp"
    to_port         = 5000
    security_groups = [aws_security_group.loadbalancer.id]
    self            = false
  }
  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Adds ecs cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
}

# Adds ECS task definition with required details
resource "aws_ecs_task_definition" "ecs_task_definition" {
  container_definitions = jsonencode([
    {
      name      = "demo-flask"
      image     = "harshalk91/demo-flask:latest"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    },
  ])
  family                   = "demo-flask"
  execution_role_arn       = data.aws_iam_role.task_ecs.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
}

resource "aws_ecs_service" "ecs_service" {
  name                 = "${var.ecs_cluster_name}-service"
  cluster              = aws_ecs_cluster.ecs_cluster.id
  task_definition      = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count        = 2
  launch_type          = "FARGATE"
  force_new_deployment = true
  load_balancer {
    container_name   = "demo-flask"
    container_port   = 5000
    target_group_arn = aws_alb_target_group.flask-target-group.arn
  }
  network_configuration {
    subnets         = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
    security_groups = [aws_security_group.ecs_security_group.id]
  }
}