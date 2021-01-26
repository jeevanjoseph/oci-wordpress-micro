variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
# variable "fingerprint" {}
# variable "private_key_path" {}
# variable "user_ocid" {}
#variable "availability_domain_name" {}


## Networking

variable "vcn" {
  default = "wpmdsvcn"
}

variable "vcn_cidr" {
  description = "VCN's CIDR IP Block"
  default     = "10.0.0.0/16"
}

## Instance

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

# MySQL

variable "admin_password" {
  description = "Password for the admin user for MySQL Database Service"
  default     = "MySQLPassw0rd!"
}

variable "admin_username" {
  description = "MySQL Database Service Username"
  default = "admin"
}


variable "wp_name" {
  description = "The username that WordPress uses to connect to the MySQL database."
  default     = "wp"  
}

variable "wp_password" {
  description = "WordPress Admin User Password."
  #default     = "MyWPpassw0rd!"  
}

variable "wp_schema" {
  description = "WordPress MySQL Schema"
  default     = "wordpress"  
}

# WordPress


