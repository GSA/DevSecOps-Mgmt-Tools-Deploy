output "jenkins_public_ip" {
  value = "${aws_eip.devsecops_mgmt_jenkins_master_eip.public_ip}"
}
