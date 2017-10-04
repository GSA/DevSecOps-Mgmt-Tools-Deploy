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
  iam_instance_profile = "${module.jenkins_master_role.profile_name}"
  jenkins_name = "${var.jenkins_master_name}"
  vm_user = "${var.jenkins_vm_user}"
}

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

data "template_file" "backup_job_vars" {
  template = "${file("${path.module}/../jenkins-jobs/jenkins-backup/job-tpl.xml")}"

  vars {
    jenkins_backup_s3_bucket = "${var.jenkins_backup_s3_bucket}"
    jenkins_backup_s3_key = "${var.jenkins_backup_s3_key}"
    region = "${var.region}"
  }
}

resource "local_file" "backup_job_rendered_file" {
    content = "${data.template_file.backup_job_vars.rendered}"
    filename = "${path.module}/../jenkins-jobs/jenkins-backup/job.xml"
}