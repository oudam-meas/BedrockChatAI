
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-southeast-2b", "ap-southeast-2c"]  # Try these AZs instead
  }
}

resource "aws_security_group" "sagemaker_notebook" {
  name        = "${var.sagemaker_instance_name}-notebook-sg"
  description = "Security group for SageMaker notebook instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "Bedrock-Course-Study"
    Owner   = "outdam"
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

resource "aws_sagemaker_notebook_instance" "domain_notebook" {
  name                    = "${var.sagemaker_instance_name}-domain-notebook"
  role_arn               = aws_iam_role.sagemaker_notebook_role.arn
  instance_type          = "ml.t2.medium"  # Changed to t2.medium which has better availability
  subnet_id              = data.aws_subnets.available.ids[0]
  security_groups        = [aws_security_group.sagemaker_notebook.id]
  direct_internet_access = "Enabled"
  lifecycle_config_name    = aws_sagemaker_notebook_instance_lifecycle_configuration.github_config.name

  tags = {
    Project = "Bedrock-Course-Study"
    Owner   = "outdam"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_sagemaker_domain.main,
    aws_iam_role_policy_attachment.sagemaker_notebook_policy_attach
  ]
}

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "github_config" {
  name = "${var.sagemaker_instance_name}-github-config"
  on_start = base64encode(<<-EOF
    #!/bin/bash
    set -e

    cd /home/ec2-user/SageMaker
    git clone https://github.com/oudam-meas/BedrockChatAI.git
    chown -R ec2-user:ec2-user bedrock-course
  EOF
  )
}

resource "aws_sagemaker_user_profile" "default_user" {
  domain_id         = aws_sagemaker_domain.main.id
  user_profile_name = "default-user"

  user_settings {
    execution_role = aws_iam_role.sagemaker_notebook_role.arn
  }

  tags = {
    Project = "Bedrock-Course-Study"
    Owner   = "outdam"
  }
}