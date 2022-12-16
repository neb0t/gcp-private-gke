locals {
  module_enabler = {
    k8s = can(var.modules["k8s"]) ? (var.modules["k8s"] ? 1 : 0) : 0
  }
}

module "gke_auth" {
  depends_on         = [module.bastion]
  source             = "../../modules/auth"
  project_id         = var.project_id
  location           = module.gke.location
  cluster_name       = module.gke.name
  bastion_proxy_ip   = module.bastion.proxy_ip
  bastion_proxy_port = module.bastion.proxy_port
  bastion_proxy_user = module.bastion.proxy_user
  bastion_proxy_pass = module.bastion.proxy_pass
}

module "gke" {
  depends_on                 = [module.network, module.bastion]
  source                     = "../../modules/private-cluster"
  project_id                 = var.project_id
  name                       = "${var.cluster_name}-${var.project_env}"
  region                     = var.region
  zones                      = var.zones
  network                    = module.network.network_name
  subnetwork                 = module.network.subnets_names[0]
  ip_range_pods              = var.ip_range_pods_name
  ip_range_services          = var.ip_range_services_name
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = false
  enable_private_endpoint    = true
  enable_private_nodes       = true
  release_channel            = "STABLE"
  master_ipv4_cidr_block     = var.master_ipv4_cidr_block

  master_authorized_networks = [
    {
      cidr_block   = "${data.google_compute_subnetwork.subnetwork.ip_cidr_range}"
      display_name = "VPC-${upper(var.project_env)}",
    },
  ]

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-medium"
      node_locations     = var.node_locations
      min_count          = 1
      max_count          = 2
      local_ssd_count    = 0
      disk_size_gb       = 30
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = "${var.gcp_profile.sa}@${var.gcp_profile.project}.iam.gserviceaccount.com"
      preemptible        = false
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "${var.project_env}-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }

}

provider "kubernetes" {
  host                   = module.gke_auth.host
  token                  = module.gke_auth.token
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  proxy_url              = "http://${module.bastion.proxy_user}:${module.bastion.proxy_pass}@${module.bastion.proxy_ip}:${module.bastion.proxy_port}"
}

resource "kubernetes_namespace" "argocd" {
  depends_on = [module.gke, module.gke_auth]
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "ingress-nginx" {
  depends_on = [module.gke, module.gke_auth]
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "argocd" {
  depends_on = [module.gke, module.gke_auth, kubernetes_namespace.argocd]
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.11.2"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
}

resource "helm_release" "ingress-nginx" {
  depends_on = [module.gke, module.gke_auth, kubernetes_namespace.ingress-nginx]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.13"
  namespace  = kubernetes_namespace.ingress-nginx.metadata.0.name
}

provider "helm" {
  kubernetes {
    config_path = local.module_enabler["k8s"] == 1 ? module.gke_auth.kube_config : null
  }
}

output "module_enabler_k8s" {
  value = local.module_enabler["k8s"]
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "zones" {
  value       = var.zones
  description = "Node Zones"
}

output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}