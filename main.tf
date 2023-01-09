data "tls_certificate" "tfc_certificate" {
  url = "https://app.terraform.io"
}

resource "aws_iam_openid_connect_provider" "default" {
  url             = var.create_tfc_oidc_provider
  client_id_list  = [var.aud_value]
  thumbprint_list = []
}

module "tfc_workload_identity_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.3.0"

  role_name        = var.tfc_workload_identity_role
  role_description = var.tfc_workload_identity_role_description
  role_policy_arns = var.tfc_workload_identity_role_policy_arns
}
  
  resource "aws_iam_role" "role" {
  name = "test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated":[aws_iam_openid_connect_provider.tfc_provider.arn]
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "app.terraform.io:aud": "${one(aws_iam_openid_connect_provider.tfc_provider.var.aud_value)}",
          "app.terraform.io:sub": "organization:Demo-Lydia:workspace:OIDC:run_phase:*"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}
