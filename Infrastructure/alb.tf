resource "aws_alb" "main" {
    name        = "ApplicationLoadBalancer"
    subnets         = aws_subnet.public.*.id
    security_groups = [aws_security_group.ALB_sg.id]
}

resource "aws_alb_target_group" "app" {
    name        = "frontend"
    port        = var.app_port
    protocol    = "HTTP"
    vpc_id      = aws_vpc.main.id
    target_type = "ip"

    health_check {
        healthy_threshold   = "3"
        interval            = "30"
        protocol            = "HTTP"
        matcher             = "200"
        timeout             = "3"
        path                = var.health_check_path
        unhealthy_threshold = "2"
    }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}
//=====================================================================================================================================
 //target group for backend
resource "aws_alb_target_group" "backend" {
    name        = "backend"
    port        = var.backend_port
    protocol    = "HTTP"
    vpc_id      = aws_vpc.main.id
    target_type = "ip"

    health_check {
        healthy_threshold   = "3"
        interval            = "30"
        protocol            = "HTTP"
        matcher             = "200"
        timeout             = "3"
        path                = var.health_check_backend
        unhealthy_threshold = "2"
    }
} 
resource "aws_alb_listener_rule" "backend" {
 listener_arn = aws_alb_listener.front_end.arn
 priority     = 60

 action {
   type             = "forward"
   target_group_arn = aws_alb_target_group.backend.arn
 }

 condition {
   path_pattern {
     values = ["/api/*"]
   }
 }
}