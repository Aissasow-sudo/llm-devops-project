variable "name" {
  type        = string
  description = "Nom du bucket Cloud Storage."
}

variable "location" {
  type        = string
  description = "Localisation du bucket (ex: US, EU)."
  default     = "US"
}

variable "storage_class" {
  type        = string
  description = "Classe de stockage du bucket."
  default     = "STANDARD"
}

variable "labels" {
  type        = map(string)
  description = "Labels appliqués au bucket."
  default     = {}
}
