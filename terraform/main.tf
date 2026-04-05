terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

resource "yandex_compute_disk" "boot-disk-hacker" {
  name     = "boot-disk-hacker"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = "fd8e9t6fpgi13oh7q39f"
}

resource "yandex_compute_disk" "boot-disk-victim" {
  name     = "boot-disk-victim"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = "fd8e9t6fpgi13oh7q39f"
}

resource "yandex_compute_instance" "hacker" {
  name = "hacker"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-hacker.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

resource "yandex_compute_instance" "victim" {
  name = "victim"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-victim.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "hacker_ip" {
  value = yandex_compute_instance.hacker.network_interface.0.nat_ip_address
}

output "victim_ip" {
  value = yandex_compute_instance.victim.network_interface.0.nat_ip_address
}
