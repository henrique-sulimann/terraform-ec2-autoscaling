resource "aws_security_group" "alb" {
  name = "ALB-SG"
  description = "Load Balancer SG"
  vpc_id = "${aws_vpc.this.id}"

  ingress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Terraform Load Balancer"
    from_port = 80
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = []
    self = false
    to_port = 80
  } ]

  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Terraform Load Balancer"
    from_port = 0
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "-1"
    security_groups = []
    self = false
    to_port = 0
  } ]

  tags = {
    Name = "Load Balancer"
  }
}

resource "aws_lb" "this" {
  name = "ALB"
  security_groups = [ "${aws_security_group.alb.id}" ]
  subnets = [ "${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}" ]

  tags = {
    Name = "ALB"
  }
}

resource "aws_lb_target_group" "tg" {
  name = "ALB-TG"
  port = 80
  protocol = "HTTP"
  vpc_id = "${aws_vpc.this.id}"

  health_check {
    path = "/"
    healthy_threshold = 2
  }
}

resource "aws_lb_listener" "lbl" {
  load_balancer_arn = "${aws_lb.this.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.tg.arn}"
  }
}