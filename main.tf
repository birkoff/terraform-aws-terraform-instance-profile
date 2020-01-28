variable "hosted_zone" {}

resource "aws_iam_role" "instance-profile-role" {
  name        = "instance-profile-role"
  path        = "/"
  description = "instance-profile-role"

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

resource "aws_iam_instance_profile" "instance-profile" {
  name = "instance-profile"
  role = "${aws_iam_role.instance-profile-role.name}"
  path = "/"
}

resource "aws_iam_role_policy" "instance-profile-policy" {
  name = "instance-profile-policy"
  role = "${aws_iam_role.instance-profile-role.id}"

  policy = <<EOP
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "elasticache:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "rds:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
          "Action": [
            "ec2:DescribeInstances"
          ],
          "Effect": "Allow",
          "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:GetParametersByPath"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:GetChange"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect" : "Allow",
            "Action" : [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource" : [
                "arn:aws:route53:::hostedzone/${var.hosted_zone}"
            ]
        }
    ]
}
EOP
}

output "iam_instance_profile" {
  value = "${aws_iam_instance_profile.instance-profile.arn}"
}
