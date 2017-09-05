output "jenkins_public_ip" {
  value = "${module.devsecops_mgmt_jenkins_master_instance.public_ip}"
}
