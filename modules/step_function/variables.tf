variable "name" {
  description = "Nombre del Step Function"
  type        = string
}

variable "role_arn" {
  description = "ARN del rol que ejecuta el Step Function"
  type        = string
}

variable "definition" {
  description = "JSON del Step Function definition"
  type        = string
}

variable "tags" {
  description = "Tags opcionales"
  type        = map(string)
  default     = {}
}
