terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Criação do Droplet Jenkins
resource "digitalocean_droplet" "jenkins" {
  image  = "ubuntu-22-04-x64"
  name   = "jenkins"
  region = var.region
  size   = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh_key.id]
}

# Data source da key criada manualmente no console
data "digitalocean_ssh_key" "ssh_key" {
  name = var.ssh_key_name
}

resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = "k8s"
  region = "nyc1"
  version = "1.26.3-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}

# Declaração das variáveis
variable "do_token" {
    default = ""
}

variable "ssh_key_name" {
    default = ""
}

variable "region" {
    default = ""
}

# Outputs
output "jenkins_ip" {
    value = digitalocean_droplet.jenkins.ipv4_address
}

# Local File do config do k8s cluster
resource "local_file" "kube_config" {
    content = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
    filename = "kube_config.yaml"
}