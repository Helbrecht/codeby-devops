terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.129.0"
    }
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "imported_vm" {
  name = "will-be-overwritten-on-import"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vm7frf0o8g7i8k0o9"  
    }
  }

  network_interface {
    subnet_id = "any-subnet-id"  
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:ssh-rsa AAAAB3NzaC1yc2E..."  
  }

  # Чтобы Terraform не пытался менять ВМ после импорта
  lifecycle {
    ignore_changes = [
      resources,
      boot_disk,
      network_interface,
      metadata,
      name
    ]
  }
}