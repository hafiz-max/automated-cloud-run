terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  # Store state locally for initial setup, can migrate to a GCS backend bucket later
  backend "local" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Artifact Registry for Container Images
resource "google_artifact_registry_repository" "app_repo" {
  location      = var.region
  repository_id = "app-images"
  description   = "Docker repository for Automated App Engine"
  format        = "DOCKER"
}

# 2. Cloud Run Service Configuration
resource "google_cloud_run_v2_service" "c_app" {
  name     = "cloud-run-c-app"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      # Placeholder initial image; pipeline updates this on push
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app_repo.repository_id}/web-app:latest"

      resources {
        limits = {
          cpu    = "1"
          memory = "128Mi" # Demonstrating resource optimization
        }
      }
    }
  }
}

# 3. Allow Public Unauthenticated Ingress
resource "google_cloud_run_v2_service_iam_binding" "public_access" {
  name     = google_cloud_run_v2_service.c_app.name
  location = google_cloud_run_v2_service.c_app.location
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}