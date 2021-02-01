terraform {
  backend "s3" {
    bucket = "terraform-tfstate-hsulimann"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}
provider "aws" {
  region = "${var.region}"
}

locals {
  tags = {
      Name = "Terraform"
  }
}

resource "aws_vpc" "this" {
  cidr_block = "${var.cidr_block}"
  tags = "${local.tags}"
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"
  tags = "${local.tags}"
}

resource "aws_subnet" "public_a" {
  vpc_id = "${aws_vpc.this.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "Public 1a"
  }
}
resource "aws_subnet" "public_b" {
  vpc_id = "${aws_vpc.this.id}"
  cidr_block = "192.168.2.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name = "Public 1b"
  }
}
resource "aws_subnet" "private_a" {
  vpc_id = "${aws_vpc.this.id}"
  cidr_block = "${var.private_a_cidr_block}"
  availability_zone = "${var.region}a"
  tags = {
    Name = "Private 1a"
  }
}
resource "aws_subnet" "private_b" {
  vpc_id = "${aws_vpc.this.id}"
  cidr_block = "${var.private_b_cidr_block}"
  availability_zone = "${var.region}b"
  tags = {
    Name = "Private 1b"
  }
}

resource "aws_route_table" "rt_public" {
  vpc_id = "${aws_vpc.this.id}"

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.this.id}"
  } 
  tags = {
    Name = "Terraform Public"
  }
}
resource "aws_route_table" "rt_private" {
  vpc_id = "${aws_vpc.this.id}"
  tags = {
    Name = "Terraform Private"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.rt_public.id}"
}

resource "aws_route_table_association" "public_b" {
  subnet_id = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.rt_public.id}"
}
resource "aws_route_table_association" "private_a" {
  subnet_id = "${aws_subnet.private_a.id}"
  route_table_id = "${aws_route_table.rt_private.id}"
}
resource "aws_route_table_association" "private_b" {
  subnet_id = "${aws_subnet.private_b.id}"
  route_table_id = "${aws_route_table.rt_private.id}"
}

resource "aws_security_group" "web" {
  name = "web-terraform"
  description = "Allow public inbound traffic"
  vpc_id = "${aws_vpc.this.id}"

  ingress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Terraform WEB"
    from_port = 80
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = []
    self = false
    to_port = 80
  },{
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Terraform WEB"
    from_port = 443
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = []
    self = false
    to_port = 443 
  } ]

  egress = [ {
    cidr_blocks = [ "${var.private_a_cidr_block}" ]
    description = "Terraform BANCO"
    from_port = 3306
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = []
    self = false
    to_port = 3306
  } ]

  tags = {
    "Name" = "Web Server"
  }
}

resource "aws_security_group" "db" {
  name = "terraform-db"
  description = "Terraform RDS"
  vpc_id = "${aws_vpc.this.id}"

  ingress = [ {
    cidr_blocks = []
    description = "Terraform Security Group DB"
    from_port = 3306
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = [ "${aws_security_group.web.id}" ]
    self = false
    to_port = 3306
  } ,
  {
    cidr_blocks = ["${var.cidr_block}"]
    description = "Terraform Security Group DB"
    from_port = 22
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = []
    self = false
    to_port = 22  
  },
  {
    cidr_blocks = ["${var.cidr_block}"]
    description = "Terraform Security Group DB"
    from_port = -1
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "icmp"
    security_groups = []
    self = false
    to_port = -1
  }]

  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Terraform Security Group DB"
    from_port = 80
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = []
    self = false
    to_port = 80
  },
  {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Terraform Security Group DB"
    from_port = 443
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = []
    self = false
    to_port = 443 
  } ]
}





