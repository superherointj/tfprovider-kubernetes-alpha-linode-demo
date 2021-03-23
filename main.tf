terraform {
  backend "remote" {
      organization = "ethical-expert"
      workspaces {
          name = "demo-lke"
      }
  }
  required_providers {
    linode = {
      source  = "linode/linode"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.3"
    }
    kubernetes-alpha = {
      source = "hashicorp/kubernetes-alpha"
      version = ">= 0.3.2"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

provider "kubernetes" {
  # This works just fine!
  # Linode's LKE resource outputs a hashed kube_config. Requiring to base64decode kubeconfig before yamldecode.
  host                   = yamldecode(base64decode(linode_lke_cluster.demo-lke.kubeconfig)).clusters[0].cluster.server
  token                  = yamldecode(base64decode(linode_lke_cluster.demo-lke.kubeconfig)).users[0].user.token
  cluster_ca_certificate = base64decode(yamldecode(base64decode(linode_lke_cluster.demo-lke.kubeconfig)).clusters[0].cluster.certificate-authority-data)
}

provider "kubernetes-alpha" {
  # Works:
  #   As kubeconfig works:
  #     $ export KUBE_VAR=`terraform output kubeconfig` && echo $KUBE_VAR | base64 -d > kubeconfig.yaml
  #   config_path = "./kubeconfig.yaml"

  # Doesn't work:
  host                   = yamldecode(base64decode(linode_lke_cluster.demo-lke.kubeconfig)).clusters[0].cluster.server
  token                  = yamldecode(base64decode(linode_lke_cluster.demo-lke.kubeconfig)).users[0].user.token
  cluster_ca_certificate = base64decode(yamldecode(base64decode(linode_lke_cluster.demo-lke.kubeconfig)).clusters[0].cluster.certificate-authority-data)

  # "client-certificate-data" and "client-key-data" are missing in kubeconfig.
  # There is only certificate-authority-data, token, server (host).
  #   How to fill client_certificate and client_key?
  
  # Sample kubeconfig file:
  #   https://pastebin.com/8LWX6Cwz

}
