variable "buckets" {
  type = list(object({
    name  = string
    layer = string
  }))
}

variable "proyecto" {
  type = string
}

variable "ambiente" {
  type = string
}
