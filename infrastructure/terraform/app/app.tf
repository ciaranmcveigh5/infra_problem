# PROVIDER

provider "aws" {
	region = "eu-west-2"
}

# # AUTO SCALING GROUP
#
# resource "aws_autoscaling_group" "infra_app" {
#     availability_zones = ["${var.availability_zone}"]
#     name = "infra_app"
#     min_size = "${var.autoscale_min}"
#     max_size = "${var.autoscale_max}"
#     min_elb_capacity = "${var.elb_min}"
#     desired_capacity = "${var.autoscale_desired}"
#     health_check_type = "EC2"
#     load_balancers = ["${aws_elb.app.name}"]
#     launch_configuration = "${aws_launch_configuration.infra_app.name}"
#     vpc_zone_identifier = ["${data.terraform_remote_state.vpc.infra_problem_public_subnet}"]
#     enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
#
#     lifecycle {
#         create_before_destroy = true
#     }
# }
#
# resource "aws_launch_configuration" "infra_app" {
#     image_id = "${var.amis}"
#     instance_type = "${var.instance_type}"
#     security_groups = ["${data.terraform_remote_state.vpc.infra_problem_base_sg}"]
#     iam_instance_profile = "${data.terraform_remote_state.jenkins.admin_iam}"
#     # TODO: is there a good way to make the key configurable sanely?
#     key_name = "${data.terraform_remote_state.jenkins.deployer_key}"
#     associate_public_ip_address = true
#
#     lifecycle {
#         create_before_destroy = true
#     }
# }

# ELBS

resource "aws_elb" "app" {
	name               = "app-elb"
	security_groups = ["${data.terraform_remote_state.vpc.infra_problem_base_sg}"]
	subnets = ["${data.terraform_remote_state.vpc.infra_problem_public_subnet}"]

	listener {
		instance_port     = 8085
		instance_protocol = "http"
		lb_port           = 80
		lb_protocol       = "http"
	}

	health_check {
		healthy_threshold   = 2
		unhealthy_threshold = 2
		timeout             = 3
		target              = "HTTP:8085/"
		interval            = 30
	}

	instances                   = ["${aws_instance.app.id}"]
	cross_zone_load_balancing   = true
	idle_timeout                = 400
	connection_draining         = true
	connection_draining_timeout = 400

	tags {
		Name = "app_elb"
	}
}

# INSTANCES

resource "aws_instance" "app" {
	ami = "ami-0a85946e"
	instance_type = "t2.small"
	security_groups = ["${data.terraform_remote_state.vpc.infra_problem_base_sg}"]
  associate_public_ip_address = true
	subnet_id = "${data.terraform_remote_state.vpc.infra_problem_public_subnet}"
	iam_instance_profile = "${data.terraform_remote_state.jenkins.admin_profile}"
	key_name = "${data.terraform_remote_state.jenkins.deployer_key}"

	tags {
		Name = "app"
	}
}
