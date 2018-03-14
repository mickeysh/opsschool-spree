# Configure AWS Provider
provider "aws" {
  region = "${var.aws_region}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.image["name"]}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "tag:Owner"
    values = ["${var.image["tagowner"]}"]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.image["tagname"]}"]
  }
}

# Get Subnet Id for the VPC
data "aws_subnet_ids" "subnets" {
  vpc_id = "${var.vpc_id}"
}

#Jenkins Security Group
resource "aws_security_group" "spree_sg" {
  name        = "spree_sg"
  description = "Security group for spress"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP from control host IP
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all SSH External
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all traffic from TCP ports 3000 and 3001
  ingress {
    from_port   = 3000
    to_port     = 3001
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allocate the EC2 Jenkins instances 
resource "aws_instance" "spree" {
  count         = "${var.spree_servers}"
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"

  subnet_id              = "${element(data.aws_subnet_ids.subnets.ids, 1)}"
  vpc_security_group_ids = ["${aws_security_group.spree_sg.id}"]
  key_name               = "${var.default_keypair_name}"

  associate_public_ip_address = true

  tags {
    Owner = "${var.owner}"
    Name  = "Spree-${count.index}"
  }
}

output "spree_server_public_ip" {
  value = "${join(",", aws_instance.spree.*.public_ip)}"
}
