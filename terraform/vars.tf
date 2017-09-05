variable "region" {
  description = "The AWS region to create resources in."
  default = "us-east-1"
}

variable "remote_state_backend_type" {
  type = "string"
}

variable "remote_state_backend_bucket" {
  type = "string"
}

variable "remote_state_backend_key" {
  type = "string"
}

variable "sg_vpc_id" {
  type = "string"
}

variable "jenkins_key_name" {
  type = "string"
}

variable "jenkins_sg_name" {
  type = "string"
}

variable "jenkins_instance_subnet_id" {
  type = "string"
}

variable "jenkins_http_cidrs" {
  type = "list"
}

variable "jenkins_ssh_cidrs" {
  type = "list"
}

variable "jenkins_master_name" {
  type = "string"
}

variable "jenkins_ami_id" {
  type = "string"
}

variable "jenkins_instance_type" {
  type = "string"
}

variable "jenkins_iam_role_name" {
  type = "string"
}

variable "jenkins_vm_user" {
  type = "string"
}
