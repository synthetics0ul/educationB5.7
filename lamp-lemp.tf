# Declaring variables for user-defined parameters

variable "zone" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "vm_image_family" {
  type = string
}

variable "vm_image_family_lemp" {
  type = string
}

variable "vm_user" {
  type = string
}

variable "ssh_key_path" {
  type = string
}

# Adding other variables

locals {
  network_name       = "web-network"
  subnet_name        = "subnet1"
  sg_vm_name         = "sg-web"
  vm_name            = "vm-lamp"
  vm_name2           = "vm-lemp"
  dns_zone_name      = "example-zone"
}

# Setting up the provider


# Creating a cloud network

resource "yandex_vpc_network" "network-1" {
  name = local.network_name
}

# Creating a subnet

resource "yandex_vpc_subnet" "subnet-1" {
  name           = local.subnet_name
  v4_cidr_blocks = ["10.130.0.0/24"]
  zone           = var.zone
  network_id     = yandex_vpc_network.network-1.id
}

# Creating a security group

resource "yandex_vpc_security_group" "sg-1" {
  name        = local.sg_vm_name
  network_id  = yandex_vpc_network.network-1.id
  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
    ingress {
    protocol       = "TCP"
    description    = "ext-ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}

# Adding a ready-made VM image

resource "yandex_compute_image" "lamp-vm-image" {
  source_family = var.vm_image_family
}

# Creating a VM

resource "yandex_compute_instance" "vm-lamp" {
  name        = local.vm_name
  platform_id = "standard-v3"
  zone        = var.zone
  resources {
    core_fraction = 20
    cores         = 2
    memory        = 1
  }
  boot_disk {
    initialize_params {
      image_id = yandex_compute_image.lamp-vm-image.id
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-1.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg-1.id]
  }
  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }

}

  resource "yandex_compute_image" "lemp-vm-image" {
  source_family = var.vm_image_family_lemp
  }

# Creating a lemp VM

resource "yandex_compute_instance" "vm-lemp" {
  name        = local.vm_name2
  platform_id = "standard-v3"
  zone        = var.zone
  resources {
    core_fraction = 20
    cores         = 2
    memory        = 1
  }
  boot_disk {
    initialize_params {
      image_id = yandex_compute_image.lemp-vm-image.id
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-1.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg-1.id]
  }
  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }
}
