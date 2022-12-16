module "bastion" {
  depends_on = [module.network]
  source     = "../../modules/bastion"

  project_id   = var.project_id
  region       = var.region
  zone         = var.bastion_zone
  bastion_name = var.bastion_name
  network_name = module.network.network_name
  subnet_name  = module.network.subnets_names[0]
  allow_from   = var.allow_from
}

output "bastion_private_ip" {
  value = module.bastion.ip
}

output "bastion_ssh_command" {
  value = module.bastion.ssh
}

output "kubectl_command" {
  value = module.bastion.kubectl_command
}

output "bastion_external_ip" {
  value = module.bastion.proxy_ip
}

output "bastion_proxy_user" {
  value     = module.bastion.proxy_user
  sensitive = true
}

output "bastion_proxy_pass" {
  value     = module.bastion.proxy_pass
  sensitive = true
}
