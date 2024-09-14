terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.66"
    }
  }

  required_version = ">= 1.9.0"
}

# Configuración del proveedor
provider "aws" {
  region = "us-east-1"
}

/*# Crear una instancia EC2
resource "aws_instance" "mi_instancia" {
  ami           = "ami-0a5c3558529277641" # AMI de Amazon Linux 2
  instance_type = "t2.micro"

  tags = {
    Name = "MiSegundaInstancia"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name-123456"  # El nombre del bucket debe ser único a nivel mundial
  acl    = "private"  # Opcional, define el control de acceso del bucket (private, public-read, etc.)

  tags = {
    Name = "my-bucket"
  }
}

# Ejemplo de salida
output "s3_bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

output "instance_id" {
  value = aws_instance.my_instance.id
}*/