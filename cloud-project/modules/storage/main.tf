resource "google_storage_bucket" "this" {
  name          = var.name
  location      = var.location
  storage_class = var.storage_class
  labels        = var.labels

  uniform_bucket_level_access = true

  # Permet à `terraform destroy` de supprimer le bucket même s'il contient
  # des objets (utile pour un environnement de test local jetable).
  force_destroy = true
}
