resource "aws_security_group" "allow_web_access_lb" {
  name_prefix = "adguard-lb-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "${var.allowed_client}/32"
    ]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "${var.allowed_client}/32"
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_lb" "adguard_lb" {
  name_prefix        = "ad-lb-"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.allow_web_access_lb.id
  ]

  subnets                    = var.subnet_list
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "adguard_target_group" {
  name_prefix = "ad-tg-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    healthy_threshold   = 5
    path                = "/login.html"
    port                = "80"
    protocol            = "HTTP"
    unhealthy_threshold = 2
    timeout             = 5
  }
}

resource "aws_lb_target_group_attachment" "adguard_target_group_attachment" {
  target_group_arn = aws_lb_target_group.adguard_target_group.arn
  target_id        = aws_instance.adguard_instance.id
  port             = 80
}

resource "aws_lb_listener" "adguard_listener" {
  load_balancer_arn = aws_lb.adguard_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.adguard_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.adguard_target_group.arn
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.adguard_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
