variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
# variable "fingerprint" {}
# variable "private_key_path" {}
# variable "user_ocid" {}
#variable "availability_domain_name" {}

variable "vcn" {
  default = "wpmdsvcn"
}

variable "vcn_cidr" {
  description = "VCN's CIDR IP Block"
  default     = "10.0.0.0/16"
}

variable "node_shape" {
  default     = "VM.Standard.E2.1"
}

variable "label_prefix" {
  default     = ""
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.8"
}

variable "generate_public_ssh_key" {
  default = true
}
variable "public_ssh_key" {
  default = ""
}

variable "admin_password" {
  description = "Password for the admin user for MySQL Database Service"
  default     = "MySQLPassw0rd!"
}

variable "admin_username" {
  description = "MySQL Database Service Username"
  default = "admin"
}


variable "wp_name" {
  description = "WordPress Database User Name."
  default     = "wp"  
}

variable "wp_password" {
  description = "WordPress Database User Password."
  default     = "MyWPpassw0rd!"  
}

variable "wp_schema" {
  description = "WordPress MySQL Schema"
  default     = "wordpress"  
}


