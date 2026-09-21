locals {
  # Préfixe commun utilisé pour nommer toutes les ressources du projet.
  resource_prefix = lower("${var.project_name}-${var.environment}")

  bucket_name       = "${local.resource_prefix}-bucket"
  pubsub_topic_name = "${local.resource_prefix}-topic"
  pubsub_sub_name   = "${local.resource_prefix}-sub"

  common_labels = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
    runtime     = "floci-gcp"
  }
}
