variable "region" {
  default     = "us-east-1"
  description = "Região primária"
}
variable "cidr_block" {
  default = "192.168.0.0/16"
}

variable "private_a_cidr_block" {
  default = "192.168.3.0/24"
}
variable "private_b_cidr_block" {
  default = "192.168.4.0/24"
}
variable "ami" {
  default = "ami-0be2609ba883822ec"
}
variable "instance_type" {
  default = "t2.micro"
}

variable "key_pair" {
  default = "terraform"
}

