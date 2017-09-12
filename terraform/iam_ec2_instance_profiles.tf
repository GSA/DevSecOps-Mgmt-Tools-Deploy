resource "aws_iam_role" "jenkins_master_ec2_role" {
    name = "${var.jenkins_iam_role_name}"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
            "Service": "ec2.amazonaws.com"
            },
                "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "jenkins_master_ec2_instance_profile" {
    name = "jenkins_master_ec2_instance_profile"
    role = "${aws_iam_role.jenkins_master_ec2_role.name}"
}