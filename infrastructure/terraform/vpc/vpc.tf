# PROVIDER

provider "aws" {
	region = "eu-west-2"
}

# VPC

resource "aws_vpc" "infra_problem" {
	cidr_block = "${var.infra_problem_vpc_cidr_range}"

	tags {
		Name = "infra_problem"
	}
}

# GATEWAYS

resource "aws_internet_gateway" "infra_problem_igw" {
  vpc_id = "${aws_vpc.infra_problem.id}"

  tags {
    Name = "infra_problem_igw"
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat_gw.id}"
  subnet_id     = "${aws_subnet.public_a.id}"
}

# ROUTE TABLE

resource "aws_route_table" "infra_problem" {
  vpc_id = "${aws_vpc.infra_problem.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.infra_problem_igw.id}"
  }

  tags {
    Name = "infra_problem"
  }
}

resource "aws_route_table_association" "infra_problem_public_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.infra_problem.id}"
}

resource "aws_route_table_association" "infra_problem_public_b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.infra_problem.id}"
}


# SUBNETS

resource "aws_subnet" "public_a" {
	vpc_id     = "${aws_vpc.infra_problem.id}"
	cidr_block = "${var.public_a_cidr_range}"
	availability_zone = "eu-west-2a"

	tags {
		Name = "public_a"
	}
}

resource "aws_subnet" "public_b" {
	vpc_id     = "${aws_vpc.infra_problem.id}"
	cidr_block = "${var.public_b_cidr_range}"
	availability_zone = "eu-west-2b"


	tags {
		Name = "public_b"
	}
}

resource "aws_subnet" "private_a" {
	vpc_id     = "${aws_vpc.infra_problem.id}"
	cidr_block = "${var.private_a_cidr_range}"
	availability_zone = "eu-west-2a"


	tags {
		Name = "private_a"
	}
}

resource "aws_subnet" "private_b" {
	vpc_id     = "${aws_vpc.infra_problem.id}"
	cidr_block = "${var.private_b_cidr_range}"
	availability_zone = "eu-west-2b"


	tags {
		Name = "private_b"
	}
}

# ELBS


# SECURITY GROUPS

resource "aws_security_group" "infra_problem_elb" {
	vpc_id     = "${aws_vpc.infra_problem.id}"
	name        = "infra_problem_elb"
	description = "elb security group"

	ingress {
		from_port   = "${var.http_port}"
		to_port     = "${var.http_port}"
		protocol    = "tcp"
		cidr_blocks = ["${var.office_cidr_range}"]
	}

}

resource "aws_security_group" "infra_problem_base" {
	vpc_id     = "${aws_vpc.infra_problem.id}"
	name        = "infra_problem_base"
	description = "Base security group"

	ingress {
		from_port   = "${var.ssh_port}"
		to_port     = "${var.ssh_port}"
		protocol    = "tcp"
		cidr_blocks = ["${var.office_cidr_range}"]
	}

	ingress {
		from_port   = "${var.http_port}"
		to_port     = "${var.http_port}"
		protocol    = "tcp"
		cidr_blocks = ["${var.office_cidr_range}"]
	}

	egress {
		from_port       = 0
		to_port         = 65535
		protocol        = "tcp"
		cidr_blocks     = ["0.0.0.0/0"]
	}
}

# EIP

resource "aws_eip" "nat_gw" {
	vpc      = true
}
