resource "aws_db_subnet_group" "db" {
  name = "terraform-db"
  subnet_ids = [ "${aws_subnet.private_a.id}", "${aws_subnet.private_b.id}" ]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "db-web" {
  allocated_storage = 10
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  name = "mydb"
  username = "henrique"
  password = "henrique#123"
  parameter_group_name = "default.mysql5.7"
  availability_zone = "${var.region}a"
  skip_final_snapshot = true

  db_subnet_group_name = "${aws_db_subnet_group.db.id}"
  vpc_security_group_ids = [ "${aws_security_group.db.id}" ]
}