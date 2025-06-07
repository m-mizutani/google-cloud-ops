# Main Terraform configuration for mztn-service project

locals {
  project_id        = "mztn-service"
  region            = "asia-northeast1"
  github_repository = "m-mizutani/google-cloud-ops"
}

# Required APIs for Workforce Identity and general operations
resource "google_project_service" "required_apis" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
  ])

  service = each.value

  disable_dependent_services = true
} 