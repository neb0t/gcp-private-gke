/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# kubeconfig

output "kubeconfig_raw" {
  sensitive   = true
  description = "A kubeconfig file configured to access the GKE cluster."
  value       = data.template_file.kubeconfig.rendered
}

# Terraform providers (kubernetes, helm)

output "cluster_ca_certificate" {
  sensitive   = true
  description = "The cluster_ca_certificate value for use with the kubernetes provider."
  value       = base64decode(local.cluster_ca_certificate)
}

output "host" {
  description = "The host value for use with the kubernetes provider."
  value       = local.host
}

output "token" {
  sensitive   = true
  description = "The token value for use with the kubernetes provider."
  value       = data.google_client_config.provider.access_token
}

output "bastion_proxy_ip" {
  description = "The bastion proxy ip."
  value       = var.bastion_proxy_ip
}

output "bastion_proxy_port" {
  description = "The bastion proxy port."
  value       = var.bastion_proxy_port
}

output "kube_config" {
  value = "${path.module}/kubeconfig-${var.cluster_name}"
}
