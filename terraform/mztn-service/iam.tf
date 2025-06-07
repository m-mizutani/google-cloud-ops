# IAM permissions for Warren service account

# Firestore access
resource "google_project_iam_member" "warren_firestore_user" {
  project = local.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.warren_runner.email}"
}

# Vertex AI access for Gemini
resource "google_project_iam_member" "warren_vertexai_user" {
  project = local.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.warren_runner.email}"
}

# Cloud Logging access
resource "google_project_iam_member" "warren_logging_writer" {
  project = local.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.warren_runner.email}"
}

# Cloud Monitoring access
resource "google_project_iam_member" "warren_monitoring_writer" {
  project = local.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.warren_runner.email}"
} 