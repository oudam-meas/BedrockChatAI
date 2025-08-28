output "sagemaker_notebook_instance_name" {
  description = "The name of the SageMaker notebook instance."
  value       = aws_sagemaker_notebook_instance.main.name
}

output "sagemaker_notebook_instance_arn" {
  description = "The ARN of the SageMaker notebook instance."
  value       = aws_sagemaker_notebook_instance.main.arn
}
