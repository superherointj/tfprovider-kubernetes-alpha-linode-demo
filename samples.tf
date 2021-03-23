# kubernetes provider demo

resource "kubernetes_namespace" "demo_namespace" {
  metadata {
    name = "demo-namespace"
  }
}

# kubernetes-alpha provider demo

resource "kubernetes_manifest" "test-configmap" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "v1"
    "kind" = "ConfigMap"
    "metadata" = {
      "name" = "test-config"
      "namespace" = "default"
    }
    "data" = {
      "foo" = "bar"
    }
  }
}

