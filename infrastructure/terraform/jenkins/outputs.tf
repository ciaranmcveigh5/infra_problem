output "deployer_key" {
  value = "${aws_key_pair.deployer_key.key_name}"
}

output "admin_iam" {
  value = "${aws_iam_role.test_role.arn}"
}

output "admin_profile" {
  value = "${aws_iam_instance_profile.jenkins_profile.name}"
}
