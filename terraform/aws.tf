provider "aws" {
  region = "${var.region}"
}

data "aws_region" "current" {
  current = true
}

terraform {
  backend "s3" {
  }
}

data "terraform_remote_state" "infrastructure_remote_state" {
    backend = "${var.remote_state_backend_type}"
    config {
        bucket = "${var.remote_state_backend_bucket}"
        key = "${var.remote_state_backend_key}"
    }
}
