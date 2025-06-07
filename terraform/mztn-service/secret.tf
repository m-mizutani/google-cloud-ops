# Secrets for Warren

# Define secret names
locals {
  warren_secrets = [
    "WARREN_SLACK_OAUTH_TOKEN",
    "WARREN_OTX_API_KEY",
    "WARREN_URLSCAN_API_KEY",
    "WARREN_SLACK_SIGNING_SECRET",
    "WARREN_VT_API_KEY",
    "WARREN_IPDB_API_KEY",
  ]
}

# Create secrets
resource "google_secret_manager_secret" "warren_secrets" {
  for_each = toset(local.warren_secrets)

  secret_id = each.value

  replication {
    auto {}
  }

  labels = {
    service = "warren"
  }
}

# Grant Warren service account access to secrets
resource "google_secret_manager_secret_iam_member" "warren_secret_access" {
  for_each = toset(local.warren_secrets)

  secret_id = google_secret_manager_secret.warren_secrets[each.key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.warren_runner.email}"
} 