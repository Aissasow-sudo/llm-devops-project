output "bucket_name" {
  description = "Nom du bucket Cloud Storage créé."
  value       = google_storage_bucket.this.name
}

output "bucket_url" {
  description = "URL gs:// du bucket."
  value       = google_storage_bucket.this.url
}
