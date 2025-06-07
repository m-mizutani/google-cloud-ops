# Cloud Run service for Warren

resource "google_cloud_run_v2_service" "warren" {
  count    = local.deploy_warren ? 1 : 0
  name     = "warren"
  location = local.region

  template {
    service_account = google_service_account.warren_runner.email

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    containers {
      image = local.warren_image_uri

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
        cpu_idle          = true
        startup_cpu_boost = false
      }

      ports {
        container_port = 8080
        name           = "http1"
      }

      # Environment variables
      env {
        name  = "WARREN_ADDR"
        value = "0.0.0.0:8080"
      }
      env {
        name  = "WARREN_LOG_FORMAT"
        value = "json"
      }
      env {
        name  = "WARREN_LOG_LEVEL"
        value = "debug"
      }
      env {
        name  = "WARREN_SLACK_CHANNEL_NAME"
        value = "alert"
      }
      env {
        name  = "WARREN_FIRESTORE_PROJECT_ID"
        value = local.project_id
      }
      env {
        name  = "WARREN_FIRESTORE_DATABASE_ID"
        value = google_firestore_database.warren_database.name
      }
      env {
        name  = "WARREN_GEMINI_PROJECT_ID"
        value = local.project_id
      }
      env {
        name  = "WARREN_EMBEDDING_PROJECT_ID"
        value = local.project_id
      }
      env {
        name  = "WARREN_STORAGE_BUCKET"
        value = "mztn-warren"
      }
      env {
        name  = "WARREN_STORAGE_PREFIX"
        value = "v0/"
      }

      # Secrets
      env {
        name = "WARREN_SLACK_OAUTH_TOKEN"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.warren_secrets["WARREN_SLACK_OAUTH_TOKEN"].secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "WARREN_OTX_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.warren_secrets["WARREN_OTX_API_KEY"].secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "WARREN_URLSCAN_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.warren_secrets["WARREN_URLSCAN_API_KEY"].secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "WARREN_SLACK_SIGNING_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.warren_secrets["WARREN_SLACK_SIGNING_SECRET"].secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "WARREN_VT_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.warren_secrets["WARREN_VT_API_KEY"].secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "WARREN_IPDB_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.warren_secrets["WARREN_IPDB_API_KEY"].secret_id
            version = "latest"
          }
        }
      }
    }
  }

  depends_on = [
    google_project_service.required_apis,
    google_service_account.warren_runner,
    google_secret_manager_secret.warren_secrets,
    google_firestore_database.warren_database,
    google_storage_bucket.warren_bucket,
  ]
}

# Allow public access to the Cloud Run service
resource "google_cloud_run_service_iam_member" "warren_public_access" {
  count = length(google_cloud_run_v2_service.warren) > 0 ? 1 : 0

  location = google_cloud_run_v2_service.warren[0].location
  service  = google_cloud_run_v2_service.warren[0].name
  role     = "roles/run.invoker"
  member   = "allUsers"
} 