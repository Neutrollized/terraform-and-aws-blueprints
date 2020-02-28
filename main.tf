terraform {
  required_version = "~> 0.11.0"
}

###------------------------------
# Network/VPC
#--------------------------------

# https://www.terraform.io/docs/providers/aws/d/availability_zones.html
data "aws_availability_zones" "zones" {}

locals {
  tags = "${map(
    "Name", "terraform-${var.environment}-vpc",
    "env", "${var.environment}",
  )}"
}

# https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags                 = "${local.tags}"
}

# https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "public" {
  count             = "${length(var.public_cidr_blocks)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.zones.names, count.index)}"
  cidr_block        = "${element(var.public_cidr_blocks, count.index)}"

  tags = "${merge(
    local.tags,
    map(
      "Name",
      "terraform-public-${substr(element(data.aws_availability_zones.zones.names, count.index), -1, 1)}"
    )
  )}"
}

resource "aws_subnet" "private" {
  count             = "${length(var.private_cidr_blocks)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.zones.names, count.index)}"
  cidr_block        = "${element(var.private_cidr_blocks, count.index)}"

  tags = "${merge(
    local.tags,
    map(
      "Name",
      "terraform-private-${substr(element(data.aws_availability_zones.zones.names, count.index), -1, 1)}",
      "subnet_type", "private"
    )
  )}"
}

###------------------------------
# IGW, EIP, NATGW & Route Table
#--------------------------------

# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
resource "aws_internet_gateway" "nomad_vpc_igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "terraform-${var.environment}-igw"
  }
}

# https://www.terraform.io/docs/providers/aws/r/eip.html
# you need the Elastic IPs to assign to the nategw
resource "aws_eip" "nat" {
  count = "${length(data.aws_availability_zones.zones.names)}"
  vpc   = true
}

# https://www.terraform.io/docs/providers/aws/r/nat_gateway.html
resource "aws_nat_gateway" "ngw" {
  count         = "${length(data.aws_availability_zones.zones.names)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"

  depends_on = ["aws_internet_gateway.nomad_vpc_igw"]
}

# https://www.terraform.io/docs/providers/aws/r/route_table.html
# this is the main route table (its gateway is the IGW)
resource "aws_route_table" "nomad_vpc_main_rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.nomad_vpc_igw.id}"
  }

  tags = {
    Name = "terraform-main-rt"
  }
}

# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
# you need a separate resource to mark the routing table (above) as main
resource "aws_main_route_table_association" "main" {
  vpc_id         = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.nomad_vpc_main_rt.id}"
}

# create routes (non-main) that uses NAT gateway
resource "aws_route_table" "nomad_vpc_ngw_rt" {
  count  = "${length(data.aws_availability_zones.zones.names)}"
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.ngw.*.id, count.index)}"
  }

  tags = {
    Name = "terraform-${substr(element(data.aws_availability_zones.zones.names, count.index), -1, 1)}-rt"
  }
}

# associate subnets with the above route(s)
resource "aws_route_table_association" "rtb_assoc_ngw_private" {
  count          = "${length(var.private_cidr_blocks)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.nomad_vpc_ngw_rt.*.id, count.index)}"
  depends_on     = ["aws_subnet.private"]
}

###------------------------------------
# EC2 instance via Autoscaling Groups 
#--------------------------------------

# https://www.terraform.io/docs/providers/aws/d/ami.html
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = ["099720109477"]
}

# https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
resource "aws_launch_configuration" "asg_conf" {
  name_prefix   = "terraform-lc-example-"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "t3a.medium"

  lifecycle {
    create_before_destroy = true
  }
}

# https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html
resource "aws_autoscaling_group" "ec2_asg" {
  name                 = "terraform-${var.environment}-asg-example"
  launch_configuration = "${aws_launch_configuration.asg_conf.name}"
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier  = ["${aws_subnet.private.*.id}"]

  lifecycle {
    create_before_destroy = true
  }

  # EC2 instance will be named 'terraform-test-node-a' (or b)
  tags = [
    {
      key                 = "Name"
      value               = "terraform-${var.environment}-node-${substr(element(data.aws_availability_zones.zones.names, count.index), -1, 1)}"
      propagate_at_launch = true
    },
  ]
}
