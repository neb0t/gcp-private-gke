module "network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 2.5"
  project_id   = var.project_id
  network_name = "${var.network}-${var.project_env}"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "${var.subnetwork}-${var.project_env}"
      subnet_ip             = var.subnetwork_ipv4_cidr_range
      subnet_region         = var.region
      subnet_private_access = true
    },
  ]
  secondary_ranges = {
    "${var.subnetwork}-${var.project_env}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = var.pod_ipv4_cidr_range
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = var.services_ipv4_cidr_range
      },
    ]
  }
}

resource "google_compute_router" "router" {
  depends_on = [module.network]
  project    = var.project_id
  name       = var.router_name
  network    = "${var.network}-${var.project_env}"
  region     = var.region
}

module "cloud-nat" {
  depends_on                         = [google_compute_router.router]
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 2.1.0"
  project_id                         = var.project_id
  region                             = var.region
  router                             = google_compute_router.router.name
  name                               = var.nat_name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
