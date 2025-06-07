# Service Account for Warren Cloud Run service

resource "google_service_account" "warren_runner" {
  account_id   = "warren-runner"
  display_name = "Warren Runner Service Account"
  description  = "Service Account for Warren Cloud Run service"
} 