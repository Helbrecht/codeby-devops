terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
}



variable "vm_name" {
  type = string
}

variable "zone" {
  type = string
}

variable "first_subnet_by_zone" {
  type = map(object({
    id   = string
    name = string
    cidr = string
  }))
}

variable "image_id" {
  type    = string
  default = "fd89nl7rpq3plgh1dmtu"  # Ubuntu 22.04 LTS
}

variable "cores"  { default = 2 }
variable "memory" { default = 2 }
variable "nat"    { default = true }

locals {
  subnet_id = var.first_subnet_by_zone[var.zone].id
}

resource "yandex_compute_instance" "vm" {
  name = var.vm_name
  zone = var.zone

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = local.subnet_id
    nat       = var.nat
  }

  metadata = {
    ssh-keys = "ubuntu:${file(pathexpand("~/.ssh/id_rsa.pub"))}"
  }
}

output "instance" {
  value       = yandex_compute_instance.vm
  description = "Полный объект созданной ВМ"
}

output "vm_ip" {
  value = var.nat ? yandex_compute_instance.vm.network_interface.0.nat_ip_address : "private"
}