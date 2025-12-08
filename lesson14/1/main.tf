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

# === VPC ===
resource "yandex_vpc_network" "net" {
  name = "lesson14-net"
}

# === Public ===
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# === NAT-gateway ===
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

# === Route table для private ===
resource "yandex_vpc_route_table" "private_nat" {
  name       = "private-nat-rt"
  network_id = yandex_vpc_network.net.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# === Private подсеть (сразу с route_table_id) ===
resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.private_nat.id   # ← привязка NAT
}

# === Security Groups ===
resource "yandex_vpc_security_group" "public_sg" {
  name       = "public-sg"
  network_id = yandex_vpc_network.net.id

  ingress {
    description    = "SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description    = "HTTP"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description    = "HTTPS"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "private_sg" {
  name       = "private-sg"
  network_id = yandex_vpc_network.net.id

  ingress {
    description    = "SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description    = "8080"
    protocol       = "TCP"
    port           = 8080
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group_rule" "allow_all_from_public_to_private" {
  security_group_binding = yandex_vpc_security_group.private_sg.id
  direction              = "ingress"
  description            = "Allow all from public subnet"
  from_port              = 0
  to_port                = 65535
  protocol               = "ANY"
  v4_cidr_blocks         = ["192.168.10.0/24"]   # ← public подсеть
}

resource "yandex_vpc_security_group_rule" "allow_all_egress_from_private" {
  security_group_binding = yandex_vpc_security_group.private_sg.id
  direction              = "egress"
  description            = "Allow all outgoing from private"
  from_port              = 0
  to_port                = 65535
  protocol               = "ANY"
  v4_cidr_blocks         = ["0.0.0.0/0"]
}


resource "yandex_vpc_security_group_rule" "allow_icmp" {
  security_group_binding = yandex_vpc_security_group.private_sg.id
  direction              = "ingress"
  description            = "Allow ping"
  protocol               = "ICMP"
  v4_cidr_blocks         = ["192.168.10.0/24"]
}




# === Public VM (Nginx на 80) ===
resource "yandex_compute_instance" "public_vm" {
  name = "public-vm"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd89nl7rpq3plgh1dmtu"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.public_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y nginx",
      "sudo systemctl enable nginx --now"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.network_interface.0.nat_ip_address
    }
  }
}

# === Private VM (Nginx на 8080) ===
resource "yandex_compute_instance" "private_vm" {
  name = "private-vm"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd89nl7rpq3plgh1dmtu"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.private_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y nginx",
      "sudo sed -i 's/80 default_server/8080 default_server/' /etc/nginx/sites-available/default",
      "sudo systemctl restart nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type                = "ssh"
      user                = "ubuntu"
      private_key         = file("~/.ssh/id_rsa")
      host                = self.network_interface.0.ip_address
      bastion_host        = yandex_compute_instance.public_vm.network_interface.0.nat_ip_address
      bastion_user        = "ubuntu"
      bastion_private_key = file("~/.ssh/id_rsa")
    }
  }
}

# === Output ===
output "public_ip" {
  value = yandex_compute_instance.public_vm.network_interface.0.nat_ip_address
}

output "private_ip" {
  value = yandex_compute_instance.private_vm.network_interface.0.ip_address
}