variable "project_name" {
  type        = string
  description = "Nom du projet, utilisé comme préfixe pour toutes les ressources."

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 20
    error_message = "project_name doit contenir entre 1 et 20 caractères."
  }
}

variable "environment" {
  type        = string
  description = "Environnement de déploiement (dev, staging, prod)."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment doit être l'une des valeurs suivantes : dev, staging, prod."
  }
}

variable "gcp_project_id" {
  type        = string
  description = "Identifiant du projet GCP (fictif, utilisé par floci-gcp). Par défaut le projet local de Floci."
  default     = "floci-local"
}

variable "gcp_region" {
  type        = string
  description = "Région GCP simulée par floci-gcp."
  default     = "us-central1"
}

variable "floci_gcp_endpoint" {
  type        = string
  description = "URL de l'endpoint local exposé par floci-gcp (remplace les endpoints réels de Google Cloud)."
  default     = "http://localhost:4588"
}

variable "storage_location" {
  type        = string
  description = "Localisation du bucket Cloud Storage."
  default     = "US"
}

variable "storage_class" {
  type        = string
  description = "Classe de stockage du bucket Cloud Storage."
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "storage_class doit être STANDARD, NEARLINE, COLDLINE ou ARCHIVE."
  }
}

variable "pubsub_ack_deadline_seconds" {
  type        = number
  description = "Délai d'acquittement (en secondes) de la souscription Pub/Sub."
  default     = 10

  validation {
    condition     = var.pubsub_ack_deadline_seconds >= 10 && var.pubsub_ack_deadline_seconds <= 600
    error_message = "pubsub_ack_deadline_seconds doit être compris entre 10 et 600."
  }
}
