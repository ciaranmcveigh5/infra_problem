output "infra_problem_vpc" {
  value = "${aws_vpc.infra_problem.id}"
}

output "infra_problem_public_subnet" {
  value = "${aws_subnet.public_a.id}"
}

output "infra_problem_public_subnet_b" {
  value = "${aws_subnet.public_b.id}"
}

output "infra_problem_private_subnet" {
  value = "${aws_subnet.private_a.id}"
}

output "infra_problem_private_subnet_b" {
  value = "${aws_subnet.private_b.id}"
}

output "infra_problem_base_sg" {
  value = "${aws_security_group.infra_problem_base.id}"
}
