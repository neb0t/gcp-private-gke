### General blurb
terraform {
  backend "gcs" {}
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.53"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.7.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.4.1"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.gcp_profile.credentials)
}
