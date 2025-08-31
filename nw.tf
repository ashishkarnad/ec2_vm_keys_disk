resource "aws_vpc" "ash25aug_vpc" {
    cidr_block = var.cidrb
    enable_dns_support = true
    
    tags = {
        Name = "ash25aug_vpc"
        environment = "dev"
        createdby = "terraform"
    }
} 

resource "aws_subnet"  "ash25aug_subnetpub1" {
    vpc_id = aws_vpc.ash25aug_vpc.id
    cidr_block =  cidrsubnet(var.cidrb, 8, 1)
    availability_zone = format("%s%s", var.region, "a")
    tags = {
        Name = "ash25aug_subnetpub1"
        environment = "dev"
        createdby = "terraform"
    }
}

resource "aws_subnet"  "ash25aug_subnetpub2" {
    vpc_id = aws_vpc.ash25aug_vpc.id
    cidr_block = cidrsubnet(var.cidrb, 8, 2)
    availability_zone = format("%s%s", var.region, "b")
        tags = {
        Name = "ash25aug_subnetpub2"
        environment = "dev"
        createdby = "terraform"
    }
}
resource "aws_subnet"  "ash25aug_subnetpvt1" {
    vpc_id = aws_vpc.ash25aug_vpc.id
    cidr_block = cidrsubnet(var.cidrb, 8, 3)
    availability_zone = format("%s%s", var.region, "c")
        tags = {
        Name = "ash25aug_subnetpvt1"
        environment = "dev"
        createdby = "terraform"
    }
    }
resource "aws_subnet"  "ash25aug_subnetpvt2" {
    vpc_id = aws_vpc.ash25aug_vpc.id
    cidr_block = cidrsubnet(var.cidrb, 8, 4)
    availability_zone = format("%s%s", var.region, "d")

        tags = {
        Name = "ash25aug_subnetpvt2"
        environment = "dev"
        createdby = "terraform"
    }
}
resource "aws_internet_gateway" "ash25aug_vpcgw" {
  vpc_id = aws_vpc.ash25aug_vpc.id

  tags = {
    Name = "main"
  }
}
resource "aws_route_table" "ash25aug_vpcrt" {
  vpc_id = aws_vpc.ash25aug_vpc.id
  tags = {
    Name = "ash25aug_vpcrt"
  }
}
resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.ash25aug_vpcrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ash25aug_vpcgw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.ash25aug_subnetpub1.id
  route_table_id = aws_route_table.ash25aug_vpcrt.id
}
# resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
#   security_group_id = aws_security_group.allow_tls.id
#   cidr_ipv4         = aws_vpc.main.cidr_block
#   from_port         = 22
#   ip_protocol       = "tcp"
#   to_port           = 22
# }
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP access"
  vpc_id      = aws_vpc.ash25aug_vpc.id

  # Inbound rule for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh_sg" {
  name        = "ssh_sg"
  description = "SSH access"
  vpc_id      = aws_vpc.ash25aug_vpc.id
  

  # Inbound rule for HTTP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "https_sg" {
  name        = "https_sg"
  description = "Allow HTTPs access"
  vpc_id      = aws_vpc.ash25aug_vpc.id

  # Inbound rule for HTTP
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}