resource "aws_kms_key" "ssm" {
  description = "KMS necryption key for SSM data"
  key_usage = "ENCRYPT_DECRYPT"
  # policy?
  tags = {
    Name = "${var.prefix} SSM KMS KEY"
  }
}

resource "aws_iam_policy" "ssm" {
  description = "Allow SSM access"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetEncryptionConfiguration"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "kms:Decrypt"
        ],
        "Resource": "${aws_kms_key.ssm.arn}"
      }
    ]
  })

  tags = {
    Name = "${var.prefix} SSM Policy"
  }
}

resource "aws_iam_role" "ssm" {
  description = "Allow EC2 instances to call SSM services"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [
    aws_iam_policy.ssm.arn
  ]
  tags = {
    Name = "${var.prefix} SSM Role"
  }
}

resource "aws_iam_instance_profile" "ssm" {
  role = aws_iam_role.ssm.name
  tags = {
    Name = "${var.prefix} SSM Instance Profile"
  }
}
