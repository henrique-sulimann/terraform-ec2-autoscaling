resource "aws_security_group" "autoscaling" {
  name = "autoscaling"
  description = "Terafform Security Group EC2"
  vpc_id = "${aws_vpc.this.id}"

  ingress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Terafform Security Group EC2"
    from_port = 22
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = []
    self = false
    to_port = 22
  },
  {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Terafform Security Group EC2"
    from_port = 80
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
    self = false
    to_port = 80  
  } ]

  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Terafform Security Group EC2"
    from_port = 0
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "-1"
    security_groups = []
    self = false
    to_port = 0
  } ]
  tags = {
    Name = "Auto Scaling"
  }
}

resource "aws_launch_configuration" "this" {
  name_prefix = "autoscaling-launcher"
  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_pair}"
  security_groups = [ "${aws_security_group.autoscaling.id}" ]

  associate_public_ip_address = true
  user_data = "${file("ec2_setup.sh")}"
}

resource "aws_autoscaling_group" "this" {
  name = "terraform-autoscaling"
  vpc_zone_identifier = [ "${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}" ]
  launch_configuration = "${aws_launch_configuration.this.name}"
  min_size = 2
  max_size = 5
  health_check_grace_period = 300
  health_check_type = "ELB"
  force_delete = true
  target_group_arns = [ "${aws_lb_target_group.tg.arn}" ]
}

resource "aws_autoscaling_policy" "scaleup" {
  name = "Scale Up"
  autoscaling_group_name = "${aws_autoscaling_group.this.name}"
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "1"
  cooldown = "300"
  policy_type = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scaledown" {
  name = "Scale Down"
  autoscaling_group_name = "${aws_autoscaling_group.this.name}"
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "-1"
  cooldown = "300"
  policy_type = "SimpleScaling"
}

resource "aws_instance" "jenkins" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"

  vpc_security_group_ids = [ "${aws_security_group.db.id}" ]
  subnet_id = "${aws_subnet.private_b.id}"
  availability_zone = "${var.region}b"

  tags = {
    Name = "JenkinsMachine"
  }
}