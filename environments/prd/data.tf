data "google_client_config" "current" {
}

data "google_service_account" "terraform" {
  account_id = var.gcp_profile.sa
}

data "google_compute_subnetwork" "subnetwork" {
  name       = "${var.subnetwork}-${var.project_env}"
  project    = var.project_id
  region     = var.region
  depends_on = [module.network]
}
