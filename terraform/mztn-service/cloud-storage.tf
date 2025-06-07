# Cloud Storage bucket for Warren

resource "google_storage_bucket" "warren_bucket" {
  name     = "mztn-warren-v1"
  location = local.region

  # Prevent destruction
  lifecycle {
    prevent_destroy = true
  }

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  # Optional: Configure lifecycle management
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }
}

# IAM binding for Warren service account to access the bucket
resource "google_storage_bucket_iam_member" "warren_bucket_access" {
  bucket = google_storage_bucket.warren_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.warren_runner.email}"
} 