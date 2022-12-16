variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "project_env" {
  type        = string
  description = "The environment for the GKE cluster"
}
variable "project_id" {
  type        = string
  description = "The project ID"
}

variable "zones" {
  type        = list(any)
  description = "The region to host the cluster in"
}

variable "node_locations" {
  type        = string
  description = "The region to host the cluster in"
}

variable "cluster_name" {
  type        = string
  description = "The name for the GKE cluster"
}

variable "network" {
  type        = string
  description = "The VPC network created to host the cluster in"
}

variable "subnetwork" {
  type        = string
  description = "The subnetwork created to host the cluster in"
}

variable "subnetwork_ipv4_cidr_range" {
  type        = string
  description = "The subnetwork ip cidr block range."
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "The subnetwork ip cidr block range."
}

variable "ip_range_pods_name" {
  type        = string
  description = "The secondary ip range to use for pods"
}

variable "pod_ipv4_cidr_range" {
  type        = string
  description = "The cidr ip range to use for pods"
}

variable "ip_range_services_name" {
  type        = string
  description = "The secondary ip range name to use for services"
}

variable "services_ipv4_cidr_range" {
  type        = string
  description = "The cidr ip range to use for services"
}

variable "region" {
  type        = string
  description = "The region to host the cluster in"
}

variable "gcp_profile" {
  description = "GCP Configuration"
  type        = map(any)
}

variable "bastion_name" {
  type        = string
  description = "The name to use for the bastion instance."
}

variable "bastion_zone" {
  type        = string
  description = "The name to use for the bastion instance."
}

variable "nat_name" {
  type        = string
  description = "The name of the NAT. Changing this forces a new NAT to be created."
}

variable "router_name" {
  type        = string
  description = "The name of the router"
}

variable "allow_from" {
  type        = string
  description = "PROXY Allow FROM rule"
}

variable "modules" {
  type        = map(bool)
  description = "Configuration for enabling terraform modules"
  default = {
    k8s : true
  }
}