resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.tags, {
    Name = local.name
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, {
    Name = "${local.name}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = { for index, az in local.azs : az => index }

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value)
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "${local.name}-public-${each.key}"
    Tier = "public"
  })
}

resource "aws_subnet" "app" {
  for_each = { for index, az in local.azs : az => index }

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 10)
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "${local.name}-app-${each.key}"
    Tier = "private-app"
  })
}

resource "aws_subnet" "firewall" {
  for_each = { for index, az in local.azs : az => index }

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 30)
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "${local.name}-firewall-${each.key}"
    Tier = "egress-firewall"
  })
}

resource "aws_subnet" "db" {
  for_each = { for index, az in local.azs : az => index }

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 20)
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "${local.name}-db-${each.key}"
    Tier = "isolated-db"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.tags, {
    Name = "${local.name}-public"
  })
}

resource "aws_route_table" "private" {
  for_each = { for index, az in local.azs : az => index }

  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = local.firewall_endpoint_ids_by_az[each.key]
  }

  tags = merge(local.tags, {
    Name = "${local.name}-private-${each.key}"
  })
}

resource "aws_route_table" "firewall" {
  for_each = { for index, az in local.azs : az => index }

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.egress[each.key].id
  }

  tags = merge(local.tags, {
    Name = "${local.name}-firewall-${each.key}"
  })
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  domain = "vpc"

  tags = merge(local.tags, {
    Name = "${local.name}-nat-${each.key}"
  })
}

resource "aws_nat_gateway" "egress" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  depends_on = [aws_internet_gateway.main]

  tags = merge(local.tags, {
    Name = "${local.name}-nat-${each.key}"
  })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "app" {
  for_each = aws_subnet.app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "db" {
  for_each = aws_subnet.db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "firewall" {
  for_each = aws_subnet.firewall

  subnet_id      = each.value.id
  route_table_id = aws_route_table.firewall[each.key].id
}
