locals {
  hostname = format("%s-bastion", var.bastion_name)
}

// Dedicated service account for the Bastion instance.
resource "google_service_account" "bastion" {
  account_id   = format("%s-bastion-sa", var.bastion_name)
  display_name = "GKE Bastion Service Account"
}

resource "random_password" "proxy_pass" {
  length      = 25
  special     = false
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
}

resource "random_password" "proxy_user" {
  length  = 9
  special = false
  lower   = true
}

// Allow access to the Bastion Host via SSH.
resource "google_compute_firewall" "bastion-ssh" {
  name          = format("%s-bastion-ssh", var.bastion_name)
  network       = var.network_name
  direction     = "INGRESS"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"] // TODO: Restrict further.

  allow {
    protocol = "tcp"
    ports    = ["22", "8888"]
  }

  target_tags = ["bastion"]
}

// The user-data script on Bastion instance provisioning.
data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy git curl unzip python3-pip jq
  sudo curl -Lq "https://dl.k8s.io/release/v1.23.0/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl && sudo chmod +x /usr/local/bin/kubectl
  sudo curl -L https://github.com/gruntwork-io/terragrunt/releases/download/v0.35.14/terragrunt_linux_amd64 -o /usr/local/bin/terragrunt
  sudo chmod +x /usr/local/bin/terragrunt
  sudo curl -L https://releases.hashicorp.com/terraform/1.1.0/terraform_1.1.0_linux_amd64.zip -o /tmp/terraform_1.1.0_linux_amd64.zip
  sudo unzip -o /tmp/terraform_1.1.0_linux_amd64.zip -d /usr/local/bin
  sudo chmod +x /usr/local/bin/terraform
  sudo curl -L https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz -o /tmp/helm-v3.7.2-linux-amd64.tar.gz
  sudo tar -xvf /tmp/helm-v3.7.2-linux-amd64.tar.gz -C /tmp
  sudo mv /tmp/linux-amd64/helm /usr/local/bin/helm
  sudo chmod +x /usr/local/bin/helm
  sudo pip3 install gcloud
  sudo echo "Allow ${var.allow_from}"  >> /etc/tinyproxy/tinyproxy.conf
  sudo echo "BasicAuth ${random_password.proxy_user.result} ${random_password.proxy_pass.result}" >> /etc/tinyproxy/tinyproxy.conf
  sudo systemctl restart tinyproxy
  EOF
}

// The Bastion host.
resource "google_compute_instance" "bastion" {
  name         = local.hostname
  machine_type = "e2-micro"
  zone         = var.zone
  project      = var.project_id
  tags         = ["bastion"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  // Install tinyproxy on startup.
  metadata_startup_script = data.template_file.startup_script.rendered

  network_interface {
    subnetwork = var.subnet_name

    access_config {
      // Not setting "nat_ip", use an ephemeral external IP.
      network_tier = "STANDARD"
    }
  }

  metadata = {
    ssh-keys = "groot:ssh-rsa BBBB3NzaC1yc2EAAAADAQABAAABAQCmsdjkL83CXFTN+NOjPjzurFUdonsdons0Bk900ganB5hdon49bovtiEKWjykkvA8jUn74avWJB3cUojJpPKdtxErIWN/SR4V5aHCF6g3TJjKvfXjr+WjNzkas15xXFmdiiHAfYp/zhTt3NwlpNOj3J/JklsRPNZF7vj8NHxJflGiraASkmK5WeNhyyRIDaaE418oRwRAqiPuk myself@me.com" # I wish I could have a time to move this to vars...
  }

  // Allow the instance to be stopped by Terraform when updating configuration.
  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform"]
  }

  /* local-exec providers may run before the host has fully initialized.
  However, they are run sequentially in the order they were defined.
  This provider is used to block the subsequent providers until the instance is available. */
  provisioner "local-exec" {
    command = <<EOF
        READY=""
        gcloud config set compute/zone
        for i in $(seq 1 20); do
          if gcloud compute ssh ${local.hostname} --project ${var.project_id} --zone ${var.zone} --command uptime; then
            READY="yes"
            break;
          fi
          echo "Waiting for ${local.hostname} to initialize..."
          sleep 10;
        done
        if [[ -z $READY ]]; then
          echo "${local.hostname} failed to start in time."
          echo "Please verify that the instance starts and then re-run `terraform apply`"
          exit 1
        fi
EOF
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }
}
