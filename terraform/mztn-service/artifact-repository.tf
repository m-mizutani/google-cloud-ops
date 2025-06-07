# Artifact Repository for container images

resource "google_artifact_registry_repository" "container_images" {
  location      = local.region
  repository_id = "container-images"
  description   = "Container images repository"
  format        = "DOCKER"

  # Clean up policy - delete images older than 32 versions
  cleanup_policy_dry_run = false
  cleanup_policies {
    id     = "delete-old-images"
    action = "DELETE"
    condition {
      tag_state             = "TAGGED"
      tag_prefixes          = ["v"]
      older_than            = "2592000s" # 30 days
      package_name_prefixes = []
    }
  }

  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      package_name_prefixes = []
      keep_count            = 32
    }
  }
} 