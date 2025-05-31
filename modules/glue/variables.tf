variable "ambiente" {
  type = string
}

variable "glue_role_arn" {
  type        = string
  description = "ARN de la IAM Role usada por Glue Job"
}

variable "source_bucket" {
  type        = string
  description = "Nombre del bucket de origen"
}

variable "target_bucket" {
  type        = string
  description = "Nombre del bucket de destino"
}