AWS Cloud Architecture Deployment (Terraform, DevOps Project)

Designed and implemented a highly available and scalable WordPress infrastructure on AWS using Infrastructure-as-Code principles with Terraform.

Architected a secure cloud environment in the eu-west-3 (Paris) region, including a custom VPC with public and private subnets across multiple Availability Zones
Implemented high availability and fault tolerance using Auto Scaling Groups (EC2 t2.micro) and an Application Load Balancer (ALB)
Deployed a multi-AZ RDS (MySQL) database (db.t3.micro) to ensure data redundancy and resilience
Configured NAT Gateways to enable secure outbound internet access for private subnets
Secured infrastructure access via a bastion host, acting as a controlled entry point
Automated AMI discovery and Availability Zone selection dynamically within Terraform
Structured Terraform code into reusable, modular components, ensuring scalability and maintainability
Implemented HTTP access (port 80) and optionally secured traffic using HTTPS (TLS, port 443)
Followed DevOps best practices, including resource tagging, variable usage (no hardcoded secrets), and reproducible deployments

Technologies: AWS (EC2, VPC, RDS, ALB, Auto Scaling), Terraform (HCL), Linux, Apache, WordPress



                           ┌───────────────────────────────┐
                           │        Internet Gateway        │
                           └──────────────┬────────────────┘
                                          │
                         ┌────────────────┴────────────────┐
                         │                                 │
              ┌──────────▼──────────┐           ┌──────────▼──────────┐
              │   Public Subnet AZ1 │           │   Public Subnet AZ2 │
              │   (10.0.128.0/20)   │           │   (10.0.144.0/20)   │
              │                     │           │                     │
              │   ┌──────────────┐  │           │  ┌──────────────┐   │
              │   │ NAT Gateway  │  │           │  │ NAT Gateway  │   │
              │   └──────┬───────┘  │           │  └──────┬───────┘   │
              │          │          │           │         │           │
              │   ┌──────▼──────┐   │           │  ┌──────▼──────┐    │
              │   │ Bastion Host│   │           │  │ Bastion Host│    │
              │   └─────────────┘   │           │  └─────────────┘    │
              └──────────┬──────────┘           └──────────┬──────────┘
                         │                                 │
                         └──────────┬──────────┬───────────┘
                                    │
                         ┌──────────▼──────────┐
                         │ Application Load    │
                         │    Balancer (ALB)   │
                         └──────────┬──────────┘
                                    │
              ┌─────────────────────┴─────────────────────┐
              │                                           │
   ┌──────────▼──────────┐                     ┌──────────▼──────────┐
   │ Private Subnet AZ1  │                     │ Private Subnet AZ2  │
   │   (10.0.0.0/19)     │                     │   (10.0.32.0/19)    │
   │                     │                     │                     │
   │ ┌─────────────────┐ │                     │ ┌─────────────────┐ │
   │ │ WordPress EC2   │◄┼── Auto Scaling ────►│ │ WordPress EC2   │ │
   │ │ (Apache)        │ │                     │ │ (Apache)        │ │
   │ └────────┬────────┘ │                     │ └────────┬────────┘ │
   │          │          │                     │          │          │
   │     ┌────▼────┐     │                     │     ┌────▼────┐     │
   │     │  RDS    │     │                     │     │  RDS    │     │
   │     │ MySQL   │     │                     │     │ MySQL   │     │
   │     └─────────┘     │                     │     └─────────┘     │
   └─────────────────────┘                     └─────────────────────┘


                ┌─────────────────────────────────────────────┐
                │                VPC (10.0.0.0/16)             │
                │     Multi-AZ, Highly Available Architecture  │
                └─────────────────────────────────────────────┘
