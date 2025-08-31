# IAM Role that allows EC2 to assume it
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Attach a managed policy to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_s3_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

#Create an Instance profile and associate the role you just defined with it
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2-s3-profile"
  role = aws_iam_role.ec2_s3_role.name
}


resource "local_file" "pet"{
    filename = "${path.module}/pet.txt"
    content = "this is pet file"
    file_permission = "0644"
    directory_permission = "0755"
}

resource "random_pet" "my_pet" {
    prefix = "my"
    separator = "."
    length = 2

}

resource "aws_instance" "ash25aug" {
    instance_type =  var.inst_types.dev
    ami = "ami-001dd4635f9fa96b0"
    key_name = aws_key_pair.ec2_key.key_name
    subnet_id = aws_subnet.ash25aug_subnetpub1.id
    associate_public_ip_address = true
    iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name
    vpc_security_group_ids = [
      aws_security_group.ssh_sg.id,
      aws_security_group.web_sg.id,
      aws_security_group.https_sg.id
    ]
    tags = {
      Name = "ash25aug_ec2"
      environment = "dev"
      createdby = "terraform"
    }
}


resource "aws_eip" "ash25aug_eip" {
//    vpc = true
    tags = {
        Name = "ash25aug_eip"
        environment = "dev"
        createdby = "terraform"
    }
}
resource "aws_egress_only_internet_gateway" "ash25aug_vpcegw" {
    vpc_id = aws_vpc.ash25aug_vpc.id
    tags = {
        Name = "ash25aug_vpcegw"
        environment = "dev"
        createdby = "terraform"
    }
}

resource "aws_key_pair" "ec2_key" {
    key_name = "ash25aug-key"
    public_key = file("${path.module}/ash25augkeypair.pub")
    tags = {
        Name = "ash25aug_keypair"
        environment = "dev"
        createdby = "terraform"
    }
}

resource "aws_ebs_volume" "ash25aug_volume" {
  availability_zone = aws_instance.ash25aug.availability_zone
  size              = 8
  type              = "gp3"

  tags = {
    Name = "ash25aug_vol_datadisk"
  }
  depends_on = [aws_instance.ash25aug]
}

resource "aws_volume_attachment" "ash25aug_vol_attach" {
    device_name = "/dev/xvdf"
    volume_id = aws_ebs_volume.ash25aug_volume.id
    instance_id = aws_instance.ash25aug.id
    force_detach = true
    skip_destroy = false
    depends_on = [aws_ebs_volume.ash25aug_volume]

}