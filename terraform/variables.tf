// Keys

variable "keypair_name" {
  default = null
}

variable "keypair_key" {
  default = null
}

// Networking

variable "loadbalancer_ip" {
  default = null
}

// Connecting to resources in other VPCs will require the VPC Peering connections.
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = []
}

// Availability zones withing region
variable "vpc_azs" {
  type        = list(string)
  description = "Availability Zones"
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}


// Loadbalancer nodes

// Loadbalancer node instance type.
// t3.micro will be enough for most users, depending on connected devices.
variable "loadbalancer_instance_type" {
  default = "t4g.nano"
}


// Loadbalancer instance disk volume size.
// We're not storing any data so any smaller volume size would work fine.
variable "loadbalancer_instance_disk_size" {
  default = "12"
}

// List of opened ports on the loadbalancer.

variable "loadbalancer_public_tcp_ports" {
  default = []
  type    = list(number)
}

variable "loadbalancer_restricted_ports_tcp" {
  default = []
  type    = list(number)
}

variable "loadbalancer_restricted_ports_allowed_ips" {
  default = []
  type    = list(string)
}

variable "loadbalancer_restricted_ports_allow_my_ip" {
  default = false
  type    = bool
}