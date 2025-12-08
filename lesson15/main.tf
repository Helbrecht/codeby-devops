terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.135.0"
    }
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

# Модуль 1: получаем все subnets в VPC
module "subnet" {
  source  = "./modules/subnet"
  vpc_id  = var.vpc_id
}

# Модуль 2: создаём ВМ (subnet выберется автоматически по zone)
module "create" {
  source              = "./modules/create"
  vm_name             = "vm"
  zone                = "ru-central1-a"
  first_subnet_by_zone = module.subnet.subnet_by_zone   # ← работает!
}

output "все_подсети" {
  value = module.subnet.debug_all_subnets
}

output "подсети_по_зонам" {
  value = module.subnet.subnet_by_zone
}

output "выбранная_подсеть_для_вм" {
  value = module.create.instance.network_interface.0.subnet_id
}

output "айпишник_вмки" {
  value = module.create.vm_ip
}