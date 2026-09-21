# Endpoints redirigés vers floci-gcp
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region

  storage_custom_endpoint = "${var.floci_gcp_endpoint}/storage/v1/"
  pubsub_custom_endpoint  = "${var.floci_gcp_endpoint}/v1/"

  access_token = "floci-local-dev-token"
}
