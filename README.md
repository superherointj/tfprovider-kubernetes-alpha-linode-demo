# Demo to test kubernetes-alpha credentials connection to Linode

Because can't connect to Linode LKE using credentials (instead of kubeconfig file).

* Terraform version: v0.14.8
* Kubernetes Alpha Provider version: v0.3.2
* Kubernetes version: v1.20.4
* Terraform Cloud: Yes.

## Source available at:

https://github.com/superherointj/tfprovider-kubernetes-alpha-linode-demo

## Brief

My kubernetes-alpha provider credentials is configured as:
```
provider "kubernetes-alpha" {
  host                   = yamldecode(base64decode(linode_lke_cluster.myapp-lke.kubeconfig)).clusters[0].cluster.server
  token                  = yamldecode(base64decode(linode_lke_cluster.myapp-lke.kubeconfig)).users[0].user.token
  cluster_ca_certificate = base64decode(yamldecode(base64decode(linode_lke_cluster.myapp-lke.kubeconfig)).clusters[0].cluster.certificate-authority-data)
}
```
But won't work. It errors as: 
`Error: Failed to construct REST client`

## Steps to reproduce:
1. `$ git clone https://github.com/superherointj/tfprovider-kubernetes-alpha-linode-demo.git`
2. `$ cd tfprovider-kubernetes-alpha-linode-demo`
2. Configure backend "remote" in `main.tf` to your `Terraform Cloud`  organization & workspace.
3. Set `linode_token` variable to your valid Linode token either at environment variable or Terraform Cloud's workspace variables (I use this).
4. `$ terraform init`
5. `$ terraform plan`

## Then, `terraform plan` exits as:

Error: Failed to construct REST client

  on samples.tf line 11, in resource "kubernetes_manifest" "test-configmap":
  11: resource "kubernetes_manifest" "test-configmap" {

cannot create REST client: no client config

## Notes

* Kubernetes-Alpha provider works fine when using `config_path = "./kubeconfig.yaml"` (file directly). But kubeconfig has no client-certificate-data or client-key-data.

* Kubernetes (official/standard) provider works perfectly with only host, cluster_ca_certificate, token from Linode's LKE. But `kubernetes-alpha` won't.

* Linode's LKE resource outputs a hashed kube_config. Requiring to base64decode kubeconfig before yamldecode.

* Sample Linode's LKE kubeconfig file: https://pastebin.com/8LWX6Cwz

* In LKE's kubeconfig `client-certificate-data` and `client-key-data` don't exist. There is only certificate-authority-data, token, server (host). How to fill in client_certificate and client_key?


## To pass test

1. `terraform plan` won't error.
2. After `terraform apply` querying kubernetes cluster should return:
  * `namespace demo_namespace` => Kubernetes provider works.
  * `ConfigMap test-config` => Kubernetes-Alpha provider works.

## Question

How to fix configuration for kubernetes-alpha provider to connect to Linode LKE using credentials?