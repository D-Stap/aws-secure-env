data "aws_caller_identity" "current" {}


# Terraform Execution Role
resource "aws_iam_role" "terraform_execution" {
  name = "terraform-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "terraform_execution" {
  name        = "terraform-execution-policy"
  description = "Policy for Terraform execution role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # VPC / Networking
      {
        Effect = "Allow"
        Action = [
          "ec2:*Vpc*",
          "ec2:*Subnet*",
          "ec2:CreateSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DeleteSecurityGroup",
          "ec2:Describe*"
        ]
        Resource = "*"
      },
      # S3 for logging bucket
      {
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:PutBucketPolicy",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutEncryptionConfiguration",
          "s3:PutBucketVersioning",
          "s3:PutBucketLogging",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = [
          var.log_bucket_arn,
          "${var.log_bucket_arn}/*"
        ]
      },
      # CloudTrail
      {
        Effect = "Allow"
        Action = [
          "cloudtrail:CreateTrail",
          "cloudtrail:UpdateTrail",
          "cloudtrail:DeleteTrail",
          "cloudtrail:StartLogging",
          "cloudtrail:StopLogging",
          "cloudtrail:GetTrail",
          "cloudtrail:ListTrails"
        ]
        Resource = "*"
      },
      # Config
      {
        Effect = "Allow"
        Action = [
          "config:PutConfigurationRecorder",
          "config:PutDeliveryChannel",
          "config:StartConfigurationRecorder",
          "config:StopConfigurationRecorder",
          "config:Describe*"
        ]
        Resource = "*"
      },
      # GuardDuty
      {
        Effect = "Allow"
        Action = [
          "guardduty:CreateDetector",
          "guardduty:UpdateDetector",
          "guardduty:DeleteDetector",
          "guardduty:GetDetector",
          "guardduty:ListDetectors"
        ]
        Resource = "*"
      },
      # IAM pass role (for services we configure)
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_execution_attach" {
  role       = aws_iam_role.terraform_execution.name
  policy_arn = aws_iam_policy.terraform_execution.arn
}

# Security ReadOnly Role
resource "aws_iam_role" "security_readonly" {
  name = "security-readonly-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "security_readonly_attach" {
  role       = aws_iam_role.security_readonly.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}
