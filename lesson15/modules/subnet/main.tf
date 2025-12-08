terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
}



variable "vpc_id" {
  type        = string
  description = "ID VPC для получения всех подсетей"
}

# Получаем VPC
data "yandex_vpc_network" "net" {
  network_id = var.vpc_id
}

# Получаем все подсети
data "yandex_vpc_subnet" "all" {
  for_each  = toset(data.yandex_vpc_network.net.subnet_ids)
  subnet_id = each.value
}

locals {
  grouped_subnets = {
    for zone in distinct([for s in data.yandex_vpc_subnet.all : s.zone]) :
    zone => element([for s in data.yandex_vpc_subnet.all : s if s.zone == zone], 0)
  }
}

output "subnet_by_zone" {
  value = {
    for zone, subnet in local.grouped_subnets : zone => {
      id   = subnet.id
      name = subnet.name
      cidr = subnet.v4_cidr_blocks[0]
    }
  }
  description = "Одна подсеть на зону — map(object)"
}

output "debug_all_subnets" {
  value = [
    for s in data.yandex_vpc_subnet.all : {
      id   = s.id
      name = s.name
      zone = s.zone
      cidr = s.v4_cidr_blocks[0]
    }
  ]
}