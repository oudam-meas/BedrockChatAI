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