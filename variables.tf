variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key ID"
  type        = string
}

variable "AWS_SECRET_KEY" {
  description = "AWS Secret Key"
  type        = string
}

variable "AWS_SESSION_TOKEN" {
  description = "AWS Session Token"
  type        = string
}

variable "AWS_COGNITO_USER_POOL_ID" {
  description = "AWS Cognito User Pool ID"
  type        = string
}

variable "AWS_COGNITO_USER_POOL_CLIENT_ID" {
  description = "AWS Cognito User Pool Client ID"
  type        = string
}

variable "AWS_COGNITO_USER_POOL_CLIENT_SECRET" {
  description = "AWS Cognito User Pool Client Secret"
  type        = string
}

variable "AWS_REGION" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "STATUS_TRACKER_DATASOURCE_USERNAME" {
  description = "Status Tracker Datasource Username"
  type        = string
}

variable "STATUS_TRACKER_DATASOURCE_PASSWORD" {
  description = "Status Tracker Datasource Password"
  type        = string
}

variable "AWS_S3_BUCKET_NAME" {
  description = "AWS S3 Bucket Name"
  type        = string
}

variable "AWS_SQS_QUEUE_NAME" {
  description = "AWS SQS Queue Name"
  type        = string
}

variable "AWS_SNS_ARN_PREFIX" {
  description = "AWS SNS ARN Prefix"
  type        = string
}




