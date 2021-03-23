resource "linode_lke_cluster" "demo-lke" {
    k8s_version = var.k8s_version
    label = var.label
    region = var.region
    tags = var.tags
    dynamic "pool" {
        for_each = var.pools
        content {
            type  = pool.value["type"]
            count = pool.value["count"]
        }
    }
}

output "kubeconfig" {
   value = linode_lke_cluster.demo-lke.kubeconfig
}

output "api_endpoints" {
   value = linode_lke_cluster.demo-lke.api_endpoints
}

output "status" {
   value = linode_lke_cluster.demo-lke.status
}

output "id" {
   value = linode_lke_cluster.demo-lke.id
}

output "pool" {
   value = linode_lke_cluster.demo-lke.pool
}
