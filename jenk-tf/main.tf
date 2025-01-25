# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.vpc_cidr

  azs = data.aws_availability_zones.azs.names
  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = var.public_subnets

  enable_dns_hostnames = true

  tags = {
    Name        = "jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
    Name = "jenkins-subnet"
  }

  public_route_table_tags = {
    Name = "jenkins-rt-pub"
  }

}


# SECURITY GROUP

module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      description = "sonarqube"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8081
      to_port     = 8081
      protocol    = "tcp"
      description = "netflix app"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      description = "Prometheus"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      description = "grafna"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "jenkins-sg"
  }
}

# EC2 INSTANCE


# Jenkins Server
module "jenkins_ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "jenkins-server"
  instance_type               = "t2.large"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = "jenkins-key"
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("jenkins-install.sh") # User data for Jenkins
  availability_zone           = data.aws_availability_zones.azs.names[0]

  ebs_block_device = [
    {
      device_name           = "/dev/xvdf"
      volume_size           = 50
      volume_type           = "gp2"
      delete_on_termination = true
    }
  ]

  tags = {
    Name        = "jenkins-server"
    Terraform   = "true"
    Environment = "dev"
  }
}

# Monitoring Server
module "monitoring_ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "monitoring-server"
  instance_type               = "t2.medium" # Different instance type
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = "jenkins-key"
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("prometheus-install.sh") # user data for installing prometheus, node exporter and grafna
  availability_zone           = data.aws_availability_zones.azs.names[0]

  ebs_block_device = [
    {
      device_name           = "/dev/xvdf"
      volume_size           = 30
      volume_type           = "gp2"
      delete_on_termination = true
    }
  ]

  tags = {
    Name        = "monitoring-server"
    Terraform   = "true"
    Environment = "dev"
  }
}
