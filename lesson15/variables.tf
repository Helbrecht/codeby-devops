variable "token" {
  type = string
  sensitive = true
}

variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "zone" {
  type = string
  default = "ru-central1-a"
}

variable "vpc_id" {
  type = string
}