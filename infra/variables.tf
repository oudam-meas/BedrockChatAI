variable "aws_region" {
  default = "ap-southeast-2"
}

variable "sagemaker_instance_name" {
  default = "genai-app-notebook"
  description = "Name of the SageMaker notebook instance"
}

variable "sagemaker_instance_type" {
  default = "ml.t3.medium"
  description = "Instance type for SageMaker notebook"
}
