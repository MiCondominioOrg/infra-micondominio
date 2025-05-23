# Configuración reusable para los 3 buckets
locals {
    buckets = [
        {
        name = "raw-apartments-management-${var.ambiente}-${var.owner}"
        layer = "Raw"
        },
        {
        name = "stage-apartments-management-${var.ambiente}-${var.owner}"
        layer = "Stage"
        },
        {
        name = "product-apartments-management-${var.ambiente}-${var.owner}"
        layer = "Product"
        }
    ]
}