variable "name" {
  description = "Name of the deployment"
  type        = string
}

variable "namespace" {
  description = "Namespace for the deployment"
  type        = string
}

variable "labels_app" {
  description = "Label for the app"
  type        = string
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "image" {
  description = "Image of the container"
  type        = string
}

variable "container_port" {
  description = "Port for the container"
  type        = number
}

variable "env_vars" {
  description = "Environment variables for the container"
  type = map(object({
    name  = string
    value = string
  }))
}

variable "resource_limits_cpu" {
  description = "CPU limit for the container"
  type        = string
}

variable "resource_limits_memory" {
  description = "Memory limit for the container"
  type        = string
}

variable "resource_requests_cpu" {
  description = "CPU request for the container"
  type        = string
}

variable "resource_requests_memory" {
  description = "Memory request for the container"
  type        = string
}

variable "restart_policy" {
  description = "Restart policy for the deployment"
  type        = string
}

variable "port" {
  description = "Port for the container"
  type        = number
}

variable "target_port" {
  description = "Port for the container"
  type        = number
}

variable "application_port" {
  description = "Port for the application"
  type        = number
}
