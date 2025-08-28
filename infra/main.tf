provider "aws" {
  region = var.aws_region
  profile = "default"
}

resource "aws_iam_role" "sagemaker_notebook_role" {
  name = "SageMakerNotebookRole-${var.sagemaker_instance_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_notebook_policy_attach" {
  role       = aws_iam_role.sagemaker_notebook_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_sagemaker_notebook_instance" "main" {
  name          = var.sagemaker_instance_name
  instance_type = var.sagemaker_instance_type
  role_arn      = aws_iam_role.sagemaker_notebook_role.arn

  tags = {
    Project = "Bedrock-Course-Study"
    Owner   = "outdam"
  }

  depends_on = [
    aws_iam_role_policy_attachment.sagemaker_notebook_policy_attach
  ]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_sagemaker_domain" "main" {
  domain_name = "${var.sagemaker_instance_name}-oudam-domain"
  auth_mode   = "IAM"
  vpc_id = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids

  default_user_settings {
    execution_role = aws_iam_role.sagemaker_notebook_role.arn
  }

  tags = {
    Project = "Bedrock-Course-Study"
    Owner   = "outdam"
  }

  depends_on = [
    aws_iam_role_policy_attachment.sagemaker_notebook_policy_attach
  ]
}