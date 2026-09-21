output "resource_prefix" {
  description = "Préfixe commun appliqué à toutes les ressources."
  value       = local.resource_prefix
}

output "storage_bucket_name" {
  description = "Nom du bucket Cloud Storage créé via floci-gcp."
  value       = module.storage.bucket_name
}

output "storage_bucket_url" {
  description = "URL du bucket Cloud Storage."
  value       = module.storage.bucket_url
}

output "pubsub_topic_name" {
  description = "Nom du topic Pub/Sub créé via floci-gcp."
  value       = module.pubsub.topic_name
}

output "pubsub_subscription_name" {
  description = "Nom de la souscription Pub/Sub."
  value       = module.pubsub.subscription_name
}
