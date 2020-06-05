##########################
# IAM: Policies and Roles
##########################


# No IAM policies currently being used. Future possibly.

# Data

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}



data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu-minimal/images/hvm-ssd/ubuntu-focal-20.04-amd64-minimal-*"]
    }

    owners = ["099720109477"] # Canonical
}



#Networking

resource "aws_vpc" "lab_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}


resource "aws_subnet" "lab_subnet" {
  vpc_id     = "${aws_vpc.lab_vpc.id}"
  cidr_block = "${var.vpc_subnet}"
}


resource "aws_internet_gateway" "lab_gw" {
  vpc_id = "${aws_vpc.lab_vpc.id}"
}

# Routing

resource "aws_route_table" "lab_rt" {
  vpc_id = "${aws_vpc.lab_vpc.id}"

  # Default route through Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.lab_gw.id}"
  }
  route {
    cidr_block = "${var.openvpn_server_internal_cidr}"
    instance_id = "${aws_instance.openvpn_server.id}"
  }
}

resource "aws_route_table_association" "lab_rta" {
  subnet_id      = "${aws_subnet.lab_subnet.id}"
  route_table_id = "${aws_route_table.lab_rt.id}"
}


#Security Group

resource "aws_security_group" "haproxy" {
  vpc_id = "${aws_vpc.lab_vpc.id}"
  name   = "haproxy-sg"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

#  ingress {
#    from_port   = 6443
#    to_port     = 6443
#    protocol    = "TCP"
#    cidr_blocks = "${var.api_whitelist}$" #todo whitelist var, the boys are @ 76.104.91.138
#  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "TCP"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"] #todo whitelist var
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"] #todo whitelist var
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "openvpn_server_sg" {
  vpc_id = "${aws_vpc.lab_vpc.id}"
  name   = "openvpn_sg"

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all traffic to Openvpn server?
  # Allow all traffic to 192.168.1.128/25?

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.haproxy.id}"]
  }

  # Allow ssh from control host IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"] #todo whitelist var
  }

  # Allow udp/1194 from control IP
  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "UDP"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"] #todo whitelist var
  }

}


#resource "aws_security_group" "k3os_sg" {
#  vpc_id = "${aws_vpc.lab_vpc.id}"
#  name   = "k3os_sg"
#
#  # Allow all outbound
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  # Allow 80 from haproxy
#
#  # Allow 443 from haproxy
#
#  # Allow all traffic to Openvpn server?
#  # Allow all traffic to 192.168.1.128/25?
#
#
#  # Allow all internal
#  ingress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["${aws_vpc.lab_vpc.cidr_block}"]
#  }
#
#  ingress {
#    from_port       = 0
#    to_port         = 0
#    protocol        = "-1"
#    security_groups = ["${aws_security_group.k3os_api.id}"]
#  }
#
#  # Allow all traffic from control host IP
#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}

#EC2



resource "aws_instance" "haproxy" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.haproxy_instance_type}"
  subnet_id                   = "${aws_subnet.lab_subnet.id}"
  associate_public_ip_address = true # Instances have public, dynamic IP
  vpc_security_group_ids      = ["${aws_security_group.haproxy.id}"]
  key_name                    = "${var.keypair_name}"
  tags = {
    Role = "loadbalancer"
  }
}


resource "aws_instance" "openvpn_server" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.openvpn_server_instance_type}"
  subnet_id                   = "${aws_subnet.lab_subnet.id}"
  associate_public_ip_address = true # Instances have public, dynamic IP
  vpc_security_group_ids      = ["${aws_security_group.openvpn_server_sg.id}"]
  key_name                    = "${var.keypair_name}"
}

#resource "aws_instance" "k3os_worker" {
#  count                       = "${var.agent_node_count}"
#  ami                         = "${var.agent_image_id}"
#  instance_type               = "${var.agent_instance_type}"
#  subnet_id                   = "${aws_subnet.lab_subnet.id}"
#  associate_public_ip_address = true # Instances have public, dynamic IP
#  vpc_security_group_ids      = ["${aws_security_group.k3os_sg.id}"]
#  key_name                    = "${var.keypair_name}"
#  user_data                   = "${templatefile("${path.module}/files/config_agent.sh", { ssh_keys = var.ssh_keys, data_sources = var.data_sources, kernel_modules = var.kernel_modules, sysctls = var.sysctls, dns_nameservers = var.dns_nameservers, ntp_servers = var.ntp_servers, k3s_cluster_secret = var.k3s_cluster_secret, k3s_server_ip = aws_instance.k3os_master.private_dns })}"
#  tags = {
#    Name                            = "k3os_worker_${count.index + 1}",
#    "kubernetes.io/cluster/default" = "owned"
#  }
#}



#Key Pair

resource "aws_key_pair" "default_keypair" {
  key_name   = "${var.keypair_name}"
  public_key = "${var.keypair_key}"
}


resource "aws_eip_association" "openvpn_server_eip_assoc" {
  instance_id   = "${aws_instance.openvpn_server.id}"
  allocation_id = "${aws_eip.openvpn_server_eip.id}"
}

resource "aws_eip" "openvpn_server_eip" {
  tags = {
    Role = "openvpn"
  }
}
