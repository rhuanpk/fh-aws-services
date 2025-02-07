terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "cluster_info" {
  depends_on = [module.eks_cluster]
  name       = module.eks_cluster.cluster_name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  depends_on = [module.eks_cluster]
  name       = module.eks_cluster.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster_info.endpoint
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_info.certificate_authority[0].data)
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "public_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = ["us-east-1a", "us-east-1b"][count.index]
  map_public_ip_on_launch = true
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow MySQL traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = aws_subnet.public_subnets.*.id

  tags = {
    Name = "MainSubnetGroup"
  }
}

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

module "eks_cluster" {
  source             = "./modules/eks-cluster"
  cluster_name       = "cluster-hackaton"
  cluster_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids         = aws_subnet.public_subnets.*.id
  kubernetes_version = "1.25"
}

module "eks_cluster_nodes" {
  source        = "./modules/nodes"
  cluster_name  = module.eks_cluster.cluster_name
  node_role_arn = module.eks_cluster.cluster_role_arn_iam
  subnet_ids    = aws_subnet.public_subnets.*.id
}

module "namespace" {
  source     = "./modules/namespaces"
  depends_on = [module.eks_cluster]
}

module "service_user" {
  source         = "./modules/service-user"
  name           = "service-user"
  namespace      = "service-user"
  labels_app     = "service-user"
  replicas       = 1
  container_name = "service-user"
  image          = "filipeborba/fh-srv-user:v2"
  container_port = 8080
  env_vars = {
    "AWS_ACCESS_KEY_ID" = {
      name  = "AWS_ACCESS_KEY_ID"
      value = var.AWS_ACCESS_KEY_ID
    }
    "AWS_SECRET_KEY" = {
      name  = "AWS_SECRET_KEY"
      value = var.AWS_SECRET_KEY
    }
    "AWS_SESSION_TOKEN" = {
      name  = "AWS_SESSION_TOKEN"
      value = var.AWS_SESSION_TOKEN
    }
    "AWS_COGNITO_USER_POOL_ID" = {
      name  = "AWS_COGNITO_USER_POOL_ID"
      value = var.AWS_COGNITO_USER_POOL_ID
    }
    "AWS_COGNITO_APP_CLIENT_ID" = {
      name  = "AWS_COGNITO_APP_CLIENT_ID"
      value = var.AWS_COGNITO_USER_POOL_CLIENT_ID
    }
    "AWS_COGNITO_APP_CLIENT_SECRET" = {
      name  = "AWS_COGNITO_APP_CLIENT_SECRET"
      value = var.AWS_COGNITO_USER_POOL_CLIENT_SECRET
    }
    "AWS_REGION" = {
      name  = "AWS_REGION"
      value = var.AWS_REGION
    }
  }
  resource_limits_cpu      = "1"
  resource_limits_memory   = "1Gi"
  resource_requests_cpu    = "500m"
  resource_requests_memory = "256Mi"
  restart_policy           = "Always"
  port                     = 8080
  target_port              = 8080
  application_port         = 4000
  depends_on               = [module.namespace]
}

output "service_user_load_balancer_hostname" {
  value = module.service_user.load_balancer_hostname
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.STATUS_TRACKER_DATASOURCE_USERNAME
  password             = var.STATUS_TRACKER_DATASOURCE_PASSWORD
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  db_name              = "status_tracker"
  publicly_accessible  = true


  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    namespace = "service-status-tracker"
    Name      = "mysql-service-status-tracker"
  }

  depends_on = [module.namespace]
}

output "mysql_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "mysql_db_name" {
  value = aws_db_instance.mysql.db_name
}

module "service_status_tracker" {
  source         = "./modules/service-status-tracker"
  name           = "service-status-tracker"
  namespace      = "service-status-tracker"
  labels_app     = "service-status-tracker"
  replicas       = 1
  container_name = "service-status-tracker"
  image          = "filipeborba/fh-srv-status-tracker:v3"
  container_port = 8080
  env_vars = {
    "SPRING_DATASOURCE_URL" = {
      name  = "SPRING_DATASOURCE_URL"
      value = "jdbc:mysql://${aws_db_instance.mysql.endpoint}/${aws_db_instance.mysql.db_name}"
    }
    "SPRING_DATASOURCE_USERNAME" = {
      name  = "SPRING_DATASOURCE_USERNAME"
      value = var.STATUS_TRACKER_DATASOURCE_USERNAME
    }
    "SPRING_DATASOURCE_PASSWORD" = {
      name  = "SPRING_DATASOURCE_PASSWORD"
      value = var.STATUS_TRACKER_DATASOURCE_PASSWORD
    }
  }
  resource_limits_cpu      = "1"
  resource_limits_memory   = "1Gi"
  resource_requests_cpu    = "500m"
  resource_requests_memory = "256Mi"
  restart_policy           = "Always"
  port                     = 8080
  target_port              = 8080
  application_port         = 4000
  depends_on               = [aws_db_instance.mysql]
}

output "service_status_tracker_load_balancer_hostname" {
  value = module.service_status_tracker.load_balancer_hostname
}

module "service_video_upload" {
  source         = "./modules/service-video-upload"
  name           = "service-video-upload"
  namespace      = "service-video-upload"
  labels_app     = "service-video-upload"
  replicas       = 1
  container_name = "service-video-upload"
  image          = "filipeborba/fh-srv-video-upload:latest"
  container_port = 8080
  env_vars = {
    "URL_AUTH_SERVICE" = {
      name  = "URL_AUTH_SERVICE"
      value = "http://${module.service_user.load_balancer_hostname}:4000/user/validateToken?token="
    }
    "URL_STATUS_TRACKER_SERVICE" = {
      name  = "URL_STATUS_TRACKER_SERVICE"
      value = "http://${module.service_status_tracker.load_balancer_hostname}:4000/videos"
    }
    "AWS_S3_ACCESS_KEY" = {
      name  = "AWS_S3_ACCESS_KEY"
      value = var.AWS_ACCESS_KEY_ID
    }
    "AWS_S3_SECRET_KEY" = {
      name  = "AWS_S3_SECRET_KEY"
      value = var.AWS_SECRET_KEY
    }
    "AWS_S3_SESSION_TOKEN" = {
      name  = "AWS_S3_SESSION_TOKEN"
      value = var.AWS_SESSION_TOKEN
    }
    "AWS_S3_REGION" = {
      name  = "AWS_S3_REGION"
      value = var.AWS_REGION
    }
    "AWS_S3_BUCKET_NAME" = {
      name  = "AWS_S3_BUCKET_NAME"
      value = var.AWS_S3_BUCKET_NAME
    }
  }
  resource_limits_cpu      = "1"
  resource_limits_memory   = "1Gi"
  resource_requests_cpu    = "500m"
  resource_requests_memory = "256Mi"
  restart_policy           = "Always"
  port                     = 8080
  target_port              = 8080
  application_port         = 4000
  depends_on               = [module.service_user, module.service_status_tracker]
}






