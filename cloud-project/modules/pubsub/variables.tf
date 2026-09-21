variable "topic_name" {
  type        = string
  description = "Nom du topic Pub/Sub."
}

variable "subscription_name" {
  type        = string
  description = "Nom de la souscription Pub/Sub rattachée au topic."
}

variable "ack_deadline_seconds" {
  type        = number
  description = "Délai d'acquittement des messages, en secondes."
  default     = 10
}

variable "labels" {
  type        = map(string)
  description = "Labels appliqués au topic et à la souscription."
  default     = {}
}
