
terraform {
  required_providers {
   kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
provider "kubernetes" {
  config_path = "~/.kube/config" 
  config_context = var.clusterArn
}


resource "kubernetes_manifest" "argocd_application_client" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "simple-client"
      namespace = "argocd" 
    }
    spec = {
      project     = "default"
      source = {
        repoURL        = "https://github.com/jrashour1/devops.git"
        targetRevision = "main"
        path            = "helm-charts"
        helm = {
          valueFiles = ["simple-client.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune       = true
          selfHeal    = true
        }
      }
    }
  }
}
resource "kubernetes_manifest" "argocd_application_api" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "simple-apis"
      namespace = "argocd" 
    }
    spec = {
      project     = "default"
      source = {
        repoURL        = "https://github.com/jrashour1/devops.git"
        targetRevision = "main"
        path            = "helm-charts"
        helm = {
          valueFiles = ["simple-api.yaml"]
        }
        
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune       = true
          selfHeal    = true
        }
      }
    }
  }
}



