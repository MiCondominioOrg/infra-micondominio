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

variable "glue_jobs" {
  description = "Lista de jobs Glue con nombre, script, buckets, etc."
  type = map(object({
    script_file    = string
    source_bucket  = string
    target_bucket  = string
    glue_role_arn  = string
  }))
}
