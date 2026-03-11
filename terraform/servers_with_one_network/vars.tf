variable "username" {}

variable "password" {}

variable "domain_name" {}

variable "project_name" {
  default = "k8s_project"
}

variable "project_user_name" {
  default = "tf_user"
}

variable "user_password" {}

variable "keypair_name" {
  default = "tf_keypair"
}

variable "auth_url" {
  default = "https://cloud.api.selcloud.ru/identity/v3"
}

variable "region" {
  default = "ru-9"
}

variable "count_of_servers" {
  default = 2
}


variable "server_name" {
  default = "k8s_server"
}

variable "server_zone" {
  default = "ru-9a"
}

variable "server_vcpus" {
  default = 2
}

variable "server_ram_mb" {
  default = 4096
}

variable "server_root_disk_gb" {
  default = 8
}

variable "server_volume_type" {
  default = "basicssd.ru-9a"
}

variable "server_image_name" {
  default = "Debian 12 (Bookworm) 64-bit"
}


variable "selectel_auth_url" {
  type        = string
  description = "Selectel Identity endpoint"
}

variable "selectel_auth_region" {
  type        = string
  description = "Selectel region"
}

variable "server_ssh_key" {
  type        = string
  description = "Name of SSH key in Selectel"
}

variable "server_ssh_key_user" {
  type        = string
  description = "Default SSH user for servers"
}
