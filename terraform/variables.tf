// Networking

// Connecting to resources in other VPCs will require the VPC Peering connections.
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

// Demo subnets for our resources.
variable "vpc_public_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

// Availability zones withing region
variable "vpc_azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

// Gateway

// Gateway instance type.
// t3.micro will be enough for most users, depending on connected devices.
variable "gateway_instance_type" {
  default = "t4g.nano"
}

// Gateway instance disk volume size.
// We're not storing any data so any smaller volume size would work fine.
variable "gateway_instance_disk_size" {
  default = "12"
}

// Wireguard primary gateway CIDR.
// This could be made to accept a list in the future?
variable "gateway_network" {
  default = "10.10.0.0/24"
}

// Kubernetes ingress nodes

// Kubernetes ingress node instance type.
// t3.micro will be enough for most users, depending on connected devices.
variable "kubernetes_ingress_instance_type" {
  default = "t4g.nano"
}

variable "kubernetes_ingress_instance_count" {
  default = "1"
}

// Kubernetes instance disk volume size.
// We're not storing any data so any smaller volume size would work fine.
variable "kubernetes_ingress_instance_disk_size" {
  default = "12"
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

