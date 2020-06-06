####################
# INFRA
####################

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "VPC CIDR"
}

variable "vpc_subnet" {
  default     = "10.0.1.0/24"
  type        = string
  description = "VPC Subnet"
}

variable "keypair_name" {
  default     = "k3s_key"
  type        = string
  description = "Keypair name"
}

variable "keypair_key" {
  default     = "ssh-rsa AAAAB3NADSKJFJDSAFdsafds example@example.com"
  type        = string
  description = "Keypair Key"
}

######################
# OpenVPN Server
######################

#variable "openvpn_server_image_id" {
#  default     = "${data.aws_ami.ubuntu}"
#  type        = string
#  description = "ami to use for openvpn, defaults to ubuntu"
#}

variable "openvpn_server_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "openvpn_server_internal_cidr" {
  type    = string
  default = "192.168.1.128/25"
}

######################
# HAProxy
#####################

variable "haproxy_eip"{
  type    	= string
  default 	= null
  description	= "EIP Association ID for the haproxy"
}

variable "haproxy_instance_type" {
  type    = string
  default = "t2.micro"
}

########################
## K3S NODE VARS
########################
#
#
#variable "k3s_args" {
#  type        = list
#  default     = []
#  description = "Additional k3s args (kube-proxy, kubelet, and controller args also go here"
#}
#
#variable "ssh_keys" {
#  type        = list
#  default     = []
#  description = "SSH Keys to inject into nodes"
#}
#
#variable "data_sources" {
#  type        = list
#  default     = ["aws"]
#  description = "data sources for node"
#}
#
#variable "kernel_modules" {
#  type        = list
#  default     = []
#  description = "kernel modules for node"
#}
#
#variable "sysctls" {
#  type        = list
#  default     = []
#  description = "sysctl params for node"
#}
#
#variable "dns_nameservers" {
#  type        = list
#  default     = ["8.8.8.8", "1.1.1.1"]
#  description = "kernel modules for node"
#}
#
#variable "ntp_servers" {
#  type        = list
#  default     = ["0.us.pool.ntp.org", "1.us.pool.ntp.org"]
#  description = "ntp servers"
#}
#
#variable "agent_image_id" {
#  type        = string
#  default     = "ami-0ed92ab0a9ecbbcf4"
#  description = "AMI to use for k3s agent instances"
#}
#
#variable "agent_instance_type" {
#  type    = string
#  default = "t2.micro"
#}
#
#variable "agent_node_count" {
#  type        = number
#  default     = 3
#  description = "Number of agent nodes to launch"
#}
