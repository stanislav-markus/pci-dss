resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type_app
  subnet_id                   = values(aws_subnet.app)[0].id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data_replace_on_change = true
  user_data                   = file("${path.module}/user_data/app.sh.tftpl")

  tags = merge(local.tags, {
    Name = "${local.name}-app"
    Tier = "cde-app"
  })
}

resource "aws_instance" "db" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type_db
  subnet_id                   = values(aws_subnet.db)[0].id
  vpc_security_group_ids      = [aws_security_group.db.id]
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data_replace_on_change = true
  user_data                   = file("${path.module}/user_data/db.sh.tftpl")

  tags = merge(local.tags, {
    Name = "${local.name}-mysql"
    Tier = "cde-db"
  })
}
