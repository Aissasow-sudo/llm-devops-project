output "topic_name" {
  description = "Nom du topic Pub/Sub créé."
  value       = google_pubsub_topic.this.name
}

output "topic_id" {
  description = "Identifiant complet du topic Pub/Sub."
  value       = google_pubsub_topic.this.id
}

output "subscription_name" {
  description = "Nom de la souscription Pub/Sub créée."
  value       = google_pubsub_subscription.this.name
}
