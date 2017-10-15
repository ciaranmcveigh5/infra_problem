# PROVIDER

provider "aws" {
	region = "eu-west-2"
}

# DATA

data "aws_ami" "ec2_linux" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn-ami-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
}

# IAM ROLES / POLICIES

resource "aws_iam_role" "jenkins_role" {
    name = "jenkinsrole"
    assume_role_policy = "${file("policies/jenkins_role.json")}"
}

resource "aws_iam_role_policy" "jenkins_admin_policy" {
    name = "jenkinpolicy"
    policy = "${file("policies/jenkins_policy.json")}"
    role = "${aws_iam_role.jenkins_role.id}"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
    name = "jenkinsprofile"
    path = "/"
    role = "${aws_iam_role.jenkins_role.name}"
}


# KEY PAIRS

resource "aws_key_pair" "deployer_key" {
  key_name   = "infra_problem"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDp01X3lVQ9NaqRFd44cajO4S2a6SMJQpr0IlW8Ke4FjcOMMavtI3oEuE7pAmu+sMEjMzitWpjlWCyA9BXGKb+mgXVKaDOKGJAVRiMRNnC0zNgAOCXIAWSo+C9oOkJioK/eNCJPb3kz5gg9o+d5kzZEkMuWEeL/u+AO1XNaaX2ryLs3yvINWo46QmSin8jtHeWTBveWWlZUCfjEFD9VkTltrD9da2WyQBjkwwgtTHNMrwY7rKIEHDs1hUE2Rp0SRKenYcqKEC3E1AOZzP5nLHTufXCtzpDvEvLgtN0XEB9iL6QaJUbNZM1o4oKAGa6XY4+9yMTkh4+qYbRG7VUsp9QR infra_problem"
}

# ELBS

resource "aws_elb" "jenkins" {
	name               = "jenkins-elb"
	security_groups = ["${data.terraform_remote_state.vpc.infra_problem_base_sg}"]
	subnets = ["${data.terraform_remote_state.vpc.infra_problem_public_subnet}"]

	listener {
		instance_port     = 8080
		instance_protocol = "http"
		lb_port           = 80
		lb_protocol       = "http"
	}

	health_check {
		healthy_threshold   = 2
		unhealthy_threshold = 2
		timeout             = 3
		target              = "HTTP:8080/"
		interval            = 30
	}

	instances                   = ["${aws_instance.jenkins.id}"]
	cross_zone_load_balancing   = true
	idle_timeout                = 400
	connection_draining         = true
	connection_draining_timeout = 400

	tags {
		Name = "jenkins_elb"
	}
}

# INSTANCES

resource "aws_instance" "jenkins" {
	ami = "ami-0a85946e"
	instance_type = "t2.large"
	vpc_security_group_ids = ["${data.terraform_remote_state.vpc.infra_problem_base_sg}"]
  associate_public_ip_address = true
	subnet_id = "${data.terraform_remote_state.vpc.infra_problem_public_subnet}"
	iam_instance_profile = "${aws_iam_instance_profile.jenkins_profile.name}"
	key_name = "${aws_key_pair.deployer_key.key_name}"

	tags {
		Name = "jenkins"
	}
}
