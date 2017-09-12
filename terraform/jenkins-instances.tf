module "devsecops_mgmt_jenkins_networking" {
  source = "../ansible/roles/external/gsa.jenkins/terraform/modules/networking"

  vpc_id = "${var.sg_vpc_id == "" ? data.terraform_remote_state.infrastructure_remote_state.mgmt_vpc_id : var.sg_vpc_id}"
  # make accessible from anywhere in the VPC
  sg_name = "${var.jenkins_sg_name}"
  http_cidrs = ["${var.jenkins_http_cidrs}"]
  ssh_cidrs = ["${var.jenkins_ssh_cidrs}"]
}

module "devsecops_mgmt_jenkins_master_instance" {
  source = "../ansible/roles/external/gsa.jenkins/terraform/modules/instances"

  ami = "${var.jenkins_ami_id}"
  instance_type = "${var.jenkins_instance_type}"
  subnet_id = "${var.jenkins_instance_subnet_id == "" ? data.terraform_remote_state.infrastructure_remote_state.mgmt_public_subnet_ids[0] : var.jenkins_instance_subnet_id}"
  vpc_security_group_ids = ["${module.devsecops_mgmt_jenkins_networking.sg_id}"]
  key_name = "${var.jenkins_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins_master_ec2_instance_profile.id}"
  jenkins_name = "${var.jenkins_master_name}"
  vm_user = "${var.jenkins_vm_user}"
}

# TODO: Need to be able to assign an EIP to the instance, rather than a public IP coming off the subnet
resource "aws_eip" "devsecops_mgmt_jenkins_master_eip" {
  vpc = true
  instance = "${module.devsecops_mgmt_jenkins_master_instance.instance_id}"
}

resource "null_resource" "eip_connection_test" {
  triggers {
    eip = "${aws_eip.devsecops_mgmt_jenkins_master_eip.public_ip}"
  }

  connection {
      host = "${aws_eip.devsecops_mgmt_jenkins_master_eip.public_ip}"
      user = "${var.jenkins_vm_user}"
      agent = true
  }

  # force Terraform to wait until a connection can be made, so that Ansible doesn't fail when trying to provision
  provisioner "remote-exec" {
    inline = [
      "echo 'Remote execution to Elastic IP address succeeded.'"
    ]
  }
}