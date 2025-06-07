# Firestore database for Warren

resource "google_firestore_database" "warren_database" {
  project     = local.project_id
  name        = "warren-v1"
  location_id = local.region
  type        = "FIRESTORE_NATIVE"

  # Prevent destruction
  lifecycle {
    prevent_destroy = true
  }
} 