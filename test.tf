##################### PROVIDER ########################
provider "aws" {
  region = "us-east-1"
}

####################### RESOURCE #######################

###################### SSH key pair ##################
resource "aws_key_pair" "kp1" {
    key_name = "kp1"
    public_key = file("nginx-server.key.pub")
}

###################### SG ########################

resource "aws_security_group" "SG1" {
    name = "SG1"
    description = "SG1 puertos 80 y 22 (ssh)"
    ingress = {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress = {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
}

######################### EC2 #########################
resource "aws_instance" "ec2-1" {
  ami = "ami-123"
  instance_type = "t2.micro"
  user_data = <<-EOF
                sudo yum install -y nginx
                sudo systemctl enable nginx
                sudo systemctl start nginx
                EOF

  key_name = aws_key_pair.kp1.key_name
  vpc_security_group_ids = [ aws_security_group.SG1.id ]
  
  tags = {
    Name = "EC2-1"
  }


}

######################### S3 bucket#########################
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl ##

resource "aws_s3_bucket" "s3-1" {
  bucket = "my-s3-bucket"
}

resource "aws_s3_bucket_ownership_controls" "s3ownership" {
  bucket = aws_s3_bucket.s3-1.id
  rule {
    #El propietario del bucket tiene control sobre todos los objetos.#
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-public-access" {
  bucket = aws_s3_bucket.s3-1.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "acl-1" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3ownership,
    aws_s3_bucket_public_access_block.s3-public-access,
  ]

  bucket = aws_s3_bucket.s3-1.id
  acl    = "public-read"
}

resource "aws_s3_object""object" {
  bucket = aws_s3_bucket.s3-1.bucket # Nombre del bucket S3
  key    = "index.html" # Nombre del objeto dentro del bucket
  source = "C:/Terraform/HolaMundo/index.html" # Ruta al archivo local que deseas subir
  acl    = "public-read"
}

resource "aws_s3_object""object" {
  bucket = aws_s3_bucket.s3-1.bucket # Nombre del bucket S3
  key    = "index.html" # Nombre del objeto dentro del bucket
  source = "C:/Terraform/HolaMundo/error.html" # Ruta al archivo local que deseas subir
  acl    = "public-read"
}

####################output###############################

output "server_ip" {
  description = "server ip"
  value = aws_instance.ec2-1.public_ip
}

output "server_dns" {
  description = "server dns"
  value = aws_instance.ec2-1.public_dns
}