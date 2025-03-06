# main.tf
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"  # Adjust this to your kubeconfig path
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"  # Adjust this to your kubeconfig path
}

# Create namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Add Helm repository
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "7.8.7"  # Use an available version from the helm search output

  values = [
    file("values.yaml")
  ]

  # Wait for the deployment to be ready
  depends_on = [kubernetes_namespace.argocd]
}

# Output the ArgoCD server URL
output "argocd_server" {
  value = "https://localhost:8080"
  description = "ArgoCD Server URL (after port-forwarding)"
}

#resource "random_string" "argocd_secretkey" {
#  length  = 32
#  special = false
#}

#resource "kubernetes_secret" "argocd_secret" {
#  metadata {
#    name      = "argocd-secret"
#    namespace = "argocd"
#  }
#  data = {
#    "server.secretkey" = base64encode(random_string.argocd_secretkey.result)
#  }
#}

output "argocd_initial_admin_password" {
  value = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  description = "Command to get initial admin password"
}