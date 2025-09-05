data "http" "myip_v4" {
  count = var.loadbalancer_restricted_ports_allow_my_ip ? 1 : 0
  url   = "https://ipv4.icanhazip.com"
  request_headers = {
    "User-Agent" = "terraform"
  }
}

locals {
  my_ip_cidr = var.loadbalancer_restricted_ports_allow_my_ip ? "${chomp(data.http.myip_v4[0].response_body)}/32" : null
  allowed_ips = var.loadbalancer_restricted_ports_allow_my_ip ? concat(var.loadbalancer_restricted_ports_allowed_ips, [local.my_ip_cidr]) : var.loadbalancer_restricted_ports_allowed_ips
}

// If provided IPs are null, do nothing
data "aws_eip" "loadbalancer_ip" {
  public_ip = var.loadbalancer_ip
  count = var.loadbalancer_ip != null ? 1 : 0
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] // canonical

  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-minimal-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}
