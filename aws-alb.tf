# Adds load balancer security group allowing HTTP traffic from anywhere
resource "aws_security_group" "loadbalancer" {
  name        = "${var.alb_name}-sg"
  description = "Allows incoming HTTP traffic to Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creates load balancer in public subnet
resource "aws_alb" "flask-loadbalancer" {
  name               = "${var.alb_name}-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadbalancer.id]
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]
  internal           = false
}

# Add Target group for port 80
resource "aws_alb_target_group" "flask-target-group" {
  name        = "${var.alb_name}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

#Ad listener listens on port 80
resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.flask-loadbalancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.flask-target-group.id
  }
}

