# Secrets for Warren

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