module "storage" {
  source = "./modules/storage"

  name          = local.bucket_name
  location      = var.storage_location
  storage_class = var.storage_class
  labels        = local.common_labels
}

module "pubsub" {
  source = "./modules/pubsub"

  topic_name           = local.pubsub_topic_name
  subscription_name    = local.pubsub_sub_name
  ack_deadline_seconds = var.pubsub_ack_deadline_seconds
  labels               = local.common_labels
}
