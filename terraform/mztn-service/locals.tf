# Local variables for mztn-service

locals {
  # Project configuration
  project_id        = "mztn-service"
  region            = "asia-northeast1"
  github_repository = "m-mizutani/google-cloud-ops"

  # Warren configuration
  deploy_warren    = true # Set to false if you don't want to deploy Warren
  warren_image_tag = "latest"
  warren_image_uri = "${local.region}-docker.pkg.dev/${local.project_id}/container-images/warren:${local.warren_image_tag}"

  # Warren secrets
  warren_secrets = [
    "WARREN_SLACK_OAUTH_TOKEN",
    "WARREN_OTX_API_KEY",
    "WARREN_URLSCAN_API_KEY",
    "WARREN_SLACK_SIGNING_SECRET",
    "WARREN_VT_API_KEY",
    "WARREN_IPDB_API_KEY",
  ]
} 