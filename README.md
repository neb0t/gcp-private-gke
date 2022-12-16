# !!!WARNING!!!

This README is not up-to-date with the code! Will try to find some time to updated it soon.
Basically this repo can help you to bootstrap your private GCP k8s cluster with Ingress and ArgoCD deployed (but not configured).
High-level concept, so some parts like local resource for k8s can be changed to store it somewhere in more secure place.
SSH publish key also must be adjusted as well as the Proxy settings and the Firewall.
I spent here more than 2 weeks to resolve some issues with provisioning and more time required to update the code to use the latest version of Terragrunt/Terraform/GCP modules and finalize the approach.


# Infrastructure

We will use `terragrunt` to bootstrap the cluster. There will not be any sensitive information in these clusters, but it's good to set it up correctly.

## Internal Tooling

We will need to be able to access the k8s cluster, so we may port forward to the following tools for usage.

## Environments

### Development GKE K8s Cluster

Use Preemptible nodes to save money.
Only use 1 availability zone.

### Production GKE k8s Cluster

Use standard nodes.
Setup 3 availability zones.

## Requirements and how to deploy clusters

1. Create GCP account
2. Install gcloud cli tool [make sure to gcloud login](https://cloud.google.com/sdk/docs#install_the_latest_cloud_tools_version_cloudsdk_current_version)
3. Install [terraform](https://www.terraform.io/downloads.html)
4. Install [terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
5. Install jq
6. Install kubectl
7. Update tf vars

Init GCP configuration:

```bash
#gcloud auth login
gcloud auth application-default login
gcloud iam service-accounts create terraform --description="service account for terraform" --display-name="terraform"
gcloud iam service-accounts list
gcloud iam service-accounts keys create ~/.ssh/terraform-gcp.json --iam-account terraform@driven-edition-333218.iam.gserviceaccount.com
gcloud auth activate-service-account terraform@driven-edition-333218.iam.gserviceaccount.com --key-file=/Users/groot/.gcp/terraform-gcp.json
gcloud services enable cloudbilling.googleapis.com --project driven-edition-333218
gcloud services enable compute.googleapis.com --project driven-edition-333218

#TO DO:
# export CLOUDSDK_CORE_PROJECT=driven-edition-333218
# gcloud projects add-iam-policy-binding driven-edition-333218 --member='serviceAccount:terraform@driven-edition-333218.iam.gserviceaccount.com' --role='roles/compute.osAdminLogin'

# Enable Compute Engine
gcloud services enable compute.googleapis.com

# Enable Billing
gcloud services enable container.googleapis.com

cd ${env}

terragrunt init
terragrunt plan
terragrunt apply
```

Kubeconfig:

```bash
export KUBECONFIG="${PWD}/kubeconfig-$ENV"
kubectl cluster-info
```

Project strucrute:

```text
.
├── README.md
├── common.tf
├── environments
│   ├── dev
│   │   ├── common.tf -> ../../common.tf
│   │   ├── gke.tf
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── terragrunt.hcl
│   └── prd
│       ├── common.tf -> ../../common.tf
│       ├── gke.tf
│       ├── main.tf
│       ├── terraform.tfvars
│       └── terragrunt.hcl
└── terragrunt.hcl
```
