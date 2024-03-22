# istio.tf

provider "kubernetes" {
  config_path    = "C:/Users/Realme/.kube/config"
  # config_context = "my-context"
}


resource "kubernetes_namespace" "example" {
  metadata {
    name = "my-first-namespace"
  }
}

######## istio install ###############

resource "helm_release" "istio_base" {
  name  = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "base"

  timeout = 120
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.example.metadata.0.name


  depends_on = [ azurerm_kubernetes_cluster.aks]
}




