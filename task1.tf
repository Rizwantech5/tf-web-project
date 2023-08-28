provider "aws" {
  region = "ap-south-1" # Set the AWS region
}

# *************************************************************
# Define an AWS security group
# resource "aws_security_group" "example" {
#   name        = "launch-wizard-2"
#   description = "launch-wizard-2 created 2023-08-28T06:34:59.693Z"
  
#   // Define your security group rules here
#   // For example, allow incoming HTTP and SSH traffic
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
  
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
# ************************************************************

# Define an AWS EC2 instance
resource "aws_instance" "web" {
  ami           = "ami-06f621d90fa29f6d0" # Specify the AMI ID
  instance_type = "t2.micro"
  key_name = "27_firstkey" # Specify the key pair
  security_groups = ["launch-wizard-1"] # Associate security groups

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("27_firstkey.pem") # Provide private key path
    host        = aws_instance.web.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd php git -y",    # Install necessary packages
      "sudo systemctl restart httpd",         # Restart the web server
      "sudo systemctl enable httpd",          # Enable the web server on boot
    ]
  }

  tags = {
    Name = "lwos1"
  }
}

# Define an AWS EBS volume
resource "aws_ebs_volume" "esb1" {
  availability_zone = aws_instance.web.availability_zone
  size              = 1
  tags = {
    Name = "lwebs"
  }
}

# Attach the EBS volume to the EC2 instance
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.esb1.id
  instance_id = aws_instance.web.id
  force_detach = true
}

# Define an output for the public IP of the instance
output "myos_ip" {
  value = aws_instance.web.public_ip
}

# Define a null resource for local execution
resource "null_resource" "nulllocal2"  {
  provisioner "local-exec" {
    command = "echo ${aws_instance.web.public_ip} > publicip.txt" # Store public IP in a file
  }
}

# Define another null resource for remote execution
resource "null_resource" "nullremote3"  {
  depends_on = [
    aws_volume_attachment.ebs_att,
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("27_firstkey.pem") # Provide private key path
    host        = aws_instance.web.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdh",              # Format the attached EBS volume
      "sudo mount /dev/xvdh /var/www/html",    # Mount the volume to /var/www/html
      "sudo rm -rf /var/www/html/*",           # Remove existing content
      "sudo git clone https://github.com/Rizwantech5/tf-web-project.git /var/www/html/"  # Clone a GitHub repository
    ]
  }
}

# Define one more null resource for local execution
resource "null_resource" "nulllocal1"  {
  depends_on = [
    null_resource.nullremote3,
  ]

  provisioner "local-exec" {
    command = "start chrome ${aws_instance.web.public_ip}" # Open the instance's public IP in Chrome
  }
}
