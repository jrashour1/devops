terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
     null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.12"
}

provider "aws" {
  region  = "eu-central-1"
  profile = "dev"
}

provider "kubernetes" {
  config_path = "~/.kube/config" 
  config_context = var.clusterArn
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"  
    config_context = var.clusterArn
  }
}

resource "null_resource" "argocd_install" {
  provisioner "local-exec" {
    command = "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
  }
}

// aws secret operator
resource "helm_release" "aws_secrets_operator" {
  name       = "aws-secrets-operator"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws/"
  chart      = "secrets-store-csi-driver-provider-aws"
  version    = "0.1.0"  
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  values = []
}

resource "kubernetes_manifest" "secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"
    metadata = {
      name = "aws-secretsmanager"
      namespace = "default"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = "eu-central-1" 
        }
      }
    }
  }
}


