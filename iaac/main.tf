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
  }
  required_version = ">= 0.12"
}

provider "aws" {
  region  = "eu-central-1"
  profile = "dev"
}

provider "kubernetes" {
  config_path = "~/.kube/config" 
  config_context = aws_eks_cluster.cluster.arn
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"  # Adjust this path if needed
    config_context = aws_eks_cluster.cluster.arn
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "eks-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone      = "eu-central-1a"
  tags = {
    Name = "eks-public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone      = "eu-central-1b"
  tags = {
    Name = "eks-private-subnet"
  }
}
resource "aws_eip" "nat" {

}
resource "aws_nat_gateway" "nat-gw" {
  subnet_id = aws_subnet.private.id
  allocation_id = aws_eip.nat.id
}
# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "eks-gateway"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "eks-public-route-table"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# EKS Cluster
resource "aws_eks_cluster" "cluster" {
  name     = "my-eks-cluster"
  role_arn  = aws_iam_role.eks.arn


  vpc_config {
    subnet_ids = [aws_subnet.public.id, aws_subnet.private.id]


  }

  depends_on = [aws_iam_role_policy_attachment.eks]
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks" {
  name = "eks-cluster-role"
  

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role     = aws_iam_role.eks.name
}
resource "aws_iam_role_policy_attachment" "eks-cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks.name
}
resource "aws_iam_role_policy_attachment" "sd" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role = aws_iam_role.eks.name
  
}

# IAM Role for Node Group
resource "aws_iam_role" "node_group" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "node_group" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role     = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role     = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role     = aws_iam_role.node_group.name
}

# EKS Node Group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = [aws_subnet.public.id]
  instance_types  = ["t2.medium"]


  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  tags = {
    Name = "my-node-group"
  }

  depends_on = [aws_eks_cluster.cluster]
}


