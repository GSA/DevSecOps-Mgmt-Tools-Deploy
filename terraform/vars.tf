variable "region" {
  description = "The AWS region to create resources in."
  default = "us-east-1"
}

variable "remote_state_backend_type" {
  description = "The remote state backend, if you’re planning to hook this up to an existing DevSecOps-Infrastructure deployment."
  type = "string"
  default = "s3"
}

variable "remote_state_backend_bucket" {
  description = "The remote state backend bucket."
  type = "string"
}

variable "remote_state_backend_key" {
  description = "The remote state key for the terraform.tfstate file. Ex: devsecops-infrastructure/terraform.tfstate"
  type = "string"
}

variable "sg_vpc_id" {
  description = "The VPC ID for the Jenkins security group. If you do not specify this, the deployment will attempt to use the vpc-mgmt VPC ID from the DevSecOps-Infrastructure deployment. You MUST have the remote_state_backend variables defined above for that to work."
  type = "string"
  default = ""
}

variable "jenkins_key_name" {
  description = "The key pair name for the Jenkins instance. The key pair must already exist in the AWS account."
  type = "string"
  default = "jenkins-master"
}

variable "jenkins_sg_name" {
  description = "The name of the new Jenkins security group."
  type = "string"
  default = "sg_jenkins_master"
}

variable "jenkins_instance_subnet_id" {
  description = "The subnet ID to place the Jenkins instance. If you do not specify this, the deployment will attempt to use the vpc-mgmt public subnet_id from the DevSecOps-Infrastructure deployment. You MUST have the remote_state_backend variables defined above for that to work."
  type = "string"
  default = ""
}

variable "jenkins_http_cidrs" {
  description = "List of CIDR ranges to allow http/https access to the instance."
  type = "list"
  default = ["0.0.0.0/0"]
}

variable "jenkins_ssh_cidrs" {
  description = "List of CIDR ranges to allow ssh access to the instances."
  type = "list"
  default = ["0.0.0.0/0"]
}

variable "jenkins_master_name" {
  description = "Name of the master instance that will be created."
  type = "string"
  default = "jenkins-master"
}

variable "jenkins_ami_id" {
  description = "AMI ID to use for the Jenkins instance."
  type = "string"
  default = "ami-a8d369c0"
}

variable "jenkins_instance_type" {
  description = "Instance type for the Jenkins instance."
  type = "string"
  default = "m4.xlarge"
}

variable "jenkins_iam_role_name" {
  description = "Name for the IAM EC2 instance role that will be created."
  type = "string"
  default = "jenkins_master_ec2_role"
}

variable "jenkins_private_master_dns" {
  description = "Private DNS hostname for the Jenkins instance"
  type = "string"
  default = "jenkins-master.devsecops.local"
}

variable "jenkins_vm_user" {
  description = "Name of the ssh user to use."
  type = "string"
  default = "ec2-user"
}
