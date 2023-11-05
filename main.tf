# Инициализация Terraform и хранения Terraform State
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
    selectel = {
      source  = "selectel/selectel"
      version = "~> 4.0.0"
    }
  }
  backend "s3" {
    bucket                      = "/test"
    endpoint                    = "s3.ru-1.storage.selcloud.ru"
    key                         = "terraform.tfstate"
    region                      = "ru-1"
    skip_region_validation      = true
    skip_credentials_validation = true
    access_key                  = "8218f4e9d*cc08d1045c4b68f"
    secret_key                  = "1827f786e95a*****8ba01f9dcd8"
  }
}

# Инициализация провайдера OpenStack
provider "openstack" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3"
  domain_name = "282***"
  tenant_id   = "102b***e35e84****11ce94a65f1ee73"
  user_name   = "Ta****"
  password    = "P*****jI"
  region      = "ru-3"
}


# Инициализация провайдера Selectel (для версии провайдера выше 4.0.0)
provider "selectel" {
  domain_name = "282553"
  username    = "Ta****"
  password    = "P*****jI"
 }

# Создание SSH-ключа
resource "openstack_compute_keypair_v2" "key_tf" {
  name       = "key_tf_n"
  region     = "ru-3"
  public_key = var.public_key
  }

# Запрос ID внешней сети по имени
data "openstack_networking_network_v2" "external_net" {
  name = "external-network"
}

# Создание роутера
resource "openstack_networking_router_v2" "router_tf" {
  name                = "router_tf"
  external_network_id = data.openstack_networking_network_v2.external_net.id
}

# Создание сети
resource "openstack_networking_network_v2" "network_tf" {
  name = "network_tf"
}

# Создание подсети
resource "openstack_networking_subnet_v2" "subnet_tf" {
  network_id = openstack_networking_network_v2.network_tf.id
  name       = "subnet_tf"
  cidr       = "10.10.0.0/24"
}

# Подключение роутера к подсети
resource "openstack_networking_router_interface_v2" "router_interface_tf" {
  router_id = openstack_networking_router_v2.router_tf.id
  subnet_id = openstack_networking_subnet_v2.subnet_tf.id
}

# Поиск ID образа (из которого будет создан сервер) по его имени
data "openstack_images_image_v2" "ubuntu_image" {
  most_recent = true
  visibility  = "public"
  name        = "Ubuntu 20.04 LTS 64-bit"
}

# Создание уникального имени флейвора
resource "random_string" "random_name_server" {
  length  = 16
  special = false
}

# Создание конфигурации сервера с 1 ГБ RAM и 1 vCPU
# Параметр disk = 0  делает сетевой диск загрузочным
resource "openstack_compute_flavor_v2" "flavor_server" {
  name      = "server-${random_string.random_name_server.result}"
  ram       = "1024"
  vcpus     = "1"
  disk      = "0"
  is_public = "false"
}

# Создание сетевого загрузочного диска размером 5 ГБ из образа
resource "openstack_blockstorage_volume_v3" "volume_server" {
  name                 = "volume-for-server1"
  size                 = "5"
  image_id             = data.openstack_images_image_v2.ubuntu_image.id
  volume_type          = "fast.ru-3b"
  availability_zone    = "ru-3b"
  enable_online_resize = true
  lifecycle {
    ignore_changes = [image_id]
  }
}

# Создание сервера
resource "openstack_compute_instance_v2" "server_tf" {
  name              = "server_tf"
  flavor_id         = openstack_compute_flavor_v2.flavor_server.id
  key_pair          = openstack_compute_keypair_v2.key_tf.id
  user_data = <<EOF
#!/bin/bash  
sudo apt-get update -y
sudo apt-get install nginx -y
ports=`netstat -tuln | grep 'LISTEN' | awk '{print "<li>Port: " $4 "</li>"}'`
echo "<html><body><h2>Ivan Stepanov</h2><br><h3>Github cod: https://github.com/ArhonTs/terraform-nginx.git </h3><br><h3>PORT OPEN:</h3><ul> $ports </ul></body></html>" > /var/www/html/index.html 
sudo service nginx start
EOF
  availability_zone = "ru-3b"
  network {
    uuid = openstack_networking_network_v2.network_tf.id
  }
  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_server.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }
  vendor_options {
    ignore_resize_confirmation = true
  }
  lifecycle {
    ignore_changes = [image_id]
  }
}

# Создание публичного IP-адреса
resource "openstack_networking_floatingip_v2" "fip_tf" {
  pool = "external-network"
}

# Привязка публичного IP-адреса к серверу
resource "openstack_compute_floatingip_associate_v2" "fip_tf" {
  floating_ip = openstack_networking_floatingip_v2.fip_tf.address
  instance_id = openstack_compute_instance_v2.server_tf.id
}


