provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "postgresql" {
  name             = "my-postgres"
  namespace        = "research"
  create_namespace = true

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "12.1.5"

  values = [
    file("${path.module}/helm/values.yaml")
  ]
}
