# In this project, we have chosen to put all the resources in this main.tf file.

# In this case we are creating a simple AWS EC2 instance.


## We specify that we are using the AWS provider. 
## Each AWS provider has its own set of API endpoints  we specify it as well.

provider "aws" {
    region = var.region
}


## We need to specify what Amazon Machine Image (AMI) we are going to be running on the EC2. We specifically want to run Ubuntu, but the "ami-id" is different in each region, and there are always new versions being uploaded. So we use the "aws_ami" data object to do the AMI lookup. 

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

## Here we define our "aws_instance" resource called example. It has the ami we specified, and the instance typ we provide as a variable.

resource "aws_instance" "basic_project" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name = aws_key_pair.basic_project.key_name
  subnet_id = aws_subnet.basic_project.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.basic_project.id]

  user_data = templatefile("${path.module}/apache_installation.sh.tpl", {
    name = var.your_name
  })

  tags = {
    Name = join("-", [var.your_name, "basic_project", "server"])
    Project = var.project
  }
}


# Here we define our security group, an resource that functions as a firewall for the EC2

resource "aws_security_group" "basic_project" {
  name        = join("-", [var.your_name, "security", "group"])
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.basic_project.id


  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"] # See data "http" "myip" below 

  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = join("-", [var.your_name, "basic_project", "server"])
    Project = var.project
  }
}

## We want to open the SSH port for our own IP address specifically.
data "http" "myip" {
    url = "https://ip.seeip.org/"
}



## Other Virtual Private Cloud (VPC) network resources
# (It is possible to direclty use the default VPC, default subnet, etc; resources that AWS already created in each region to make things easier for a new customer. But I am including all of these here because in a production-type CI/CD pipeline we would be creating these networking resources from scratch.)

resource "aws_vpc" "basic_project" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = join("_", [var.your_name, "vpc"])
    Project = var.project
  }
}


resource "aws_internet_gateway" "basic_project" {
  vpc_id = aws_vpc.basic_project.id

  tags = {
    Name = join("_", [var.your_name, "ig"])
    Project = var.project
  }
}

resource "aws_subnet" "basic_project" {
  vpc_id     = aws_vpc.basic_project.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = join("_", [var.your_name, "subnet"])
    Project = var.project
  }
}

resource "aws_route_table" "basic_project" {
  vpc_id = aws_vpc.basic_project.id

  tags = {
    Name = join("_", [var.your_name, "route_table"])
    Project = var.project
  }
}

resource "aws_route" "basic_project" {
  route_table_id         = aws_route_table.basic_project.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.basic_project.id
}


resource "aws_route_table_association" "basic_project" {
  subnet_id      = aws_subnet.basic_project.id
  route_table_id = aws_route_table.basic_project.id
}










## We generate a key-pair so we can SSH into the instance

# WARNING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# DO NOT USE THIS FOR PRODUCTION!!! OR FOR ANYTHING OTHER THAN TESTING THINGS OUT!
# Using these Terraform resources will have the private key be stored as CLEARTEXT in the terraform.tfstate file!!!!

# There are other ways of dealing with this, like creating the keys as part of a DIFFERENT step, using some other scripting tool.

resource "tls_private_key" "basic_project" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "basic_project" {
  key_name   = join("-", [var.your_name, var.project, "key"])
  public_key = tls_private_key.basic_project.public_key_openssh
}

resource "local_file" "key" {
  content  = tls_private_key.basic_project.private_key_pem
  filename = "${aws_key_pair.basic_project.key_name}.pem"
}
