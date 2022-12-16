### Environment-specific options
project_env                = "dev"
project_id                 = "driven-edition-333218"
region                     = "europe-west1"
cluster_name               = "earn-something"
network                    = "gke-network"
subnetwork                 = "gke-subnet"
subnetwork_ipv4_cidr_range = "10.10.0.0/16"
ip_range_pods_name         = "ip-range-pods"
pod_ipv4_cidr_range        = "10.20.0.0/16"
ip_range_services_name     = "ip-range-services"
services_ipv4_cidr_range   = "10.30.0.0/16"
master_ipv4_cidr_block     = "10.0.0.0/28"
zones                      = ["europe-west1-b"]
node_locations             = "europe-west1-b"
gcp_profile = {
  project     = "driven-edition-333218"
  credentials = "/Users/groot/.gcp/terraform-gcp.json"
  sa          = "terraform"
}
bastion_name = "dev-cluster"
bastion_zone = "europe-west1-b"
nat_name     = "dev-gke-nat"
router_name  = "dev-gke-router"
allow_from   = "84.237.170.190" # Here is allowed IP address
