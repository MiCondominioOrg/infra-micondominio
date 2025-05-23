variable "region" {
    description = "Nombre de la region"
    type        = string
    default     = "us-east-1"
}

variable "owner" {
    description = "Número de la cuenta"
    type        = string
}

variable "proyecto" {
    description = "Nombre del proyecto"
    type        = string
}

variable "ambiente" {
    description = "Nombre del ambiente"
    type        = string
}

variable "glue_role_name" {
    description = "Nombre del rol IAM para Glue"
    type        = string
}

variable "glue_policy_name" {
    description = "Nombre de la policy IAM"
    type        = string
}

