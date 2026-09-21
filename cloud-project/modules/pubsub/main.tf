resource "google_pubsub_topic" "this" {
  name   = var.topic_name
  labels = var.labels
}

resource "google_pubsub_subscription" "this" {
  name  = var.subscription_name
  topic = google_pubsub_topic.this.name

  ack_deadline_seconds = var.ack_deadline_seconds
  labels               = var.labels
}
