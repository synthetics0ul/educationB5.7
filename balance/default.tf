terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.90.0"

    }
  }
}
locals {
  folder_id = "b1g8dtfapo33lj1ugosq"
  cloud_id  = "b1gfgrc4pa5k55ot2c70"
}
provider "yandex" {
  cloud_id                 = local.cloud_id
  folder_id                = local.folder_id
  service_account_key_file = "/home/srs.lan/dkulik/terraform/authorized_key.json"
  zone = "ru-central1-a"
}