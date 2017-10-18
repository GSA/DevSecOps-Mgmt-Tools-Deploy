module "jenkins_master_role" {
    source = "github.com/18F/cg-provision/terraform/modules/iam_role"
    role_name = "${var.jenkins_iam_role_name}"
}

module "cloudwatch_policy" {
    source = "github.com/GSA/DevSecOps-Infrastructure/terraform/modules/iam_role_policy/cloudwatch"
    policy_name = "${var.jenkins_master_name}-cloudwatch"
}

resource "aws_iam_policy_attachment" "cloudwatch" {
name = "${var.jenkins_master_name}-cloudwatch"
  policy_arn = "${module.cloudwatch_policy.arn}"
  roles = [
    "${module.jenkins_master_role.role_name}"
  ]
}