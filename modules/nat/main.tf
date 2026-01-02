resource "aws_eip" "nat_eip" {
  domain   = "vpc"  
  instance = aws_instance.nat.id
}

resource "aws_instance" "nat" {
  ami                         = "ami-01ad0c7a4930f0e43"  
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
#   vpc_security_group_ids      = [var.nat_sg_id]
  source_dest_check           = false
  associate_public_ip_address = false

  tags = {
    Name = "nat-instance"
  }
}

resource "aws_eip_association" "nat_eip_assoc" {
  instance_id   = aws_instance.nat.id
  allocation_id = aws_eip.nat_eip.id
}