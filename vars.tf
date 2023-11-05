# Пул Облачной платформы 
variable "region" {
  default = "ru-3"
}

# Значение SSH-ключа для доступа к облачному серверу
variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDcSE6Dfa94I0glnKkMrg/4OaL3qV8LsiUrdzNLbUV2w325yEM3XWsY6PUNBpZkRGL+M40XgXsTFsZbH7DM+/pkT8PGMVVtcD/6TGBw27tI2IKwN12hyos8HVnz1kiWtL2oJyxEUB0KCuRNts/IMnRplKO6/e7ZTBQprNhFH6uF++W3Oc4ggXn286nzo8O3xMbxIYNNbf6fc6wzIbqk8f9eA/tyKrJ5adBOKk1SeqwJbzpmYgTEaG05siDE8MspWfiNc0bdgN1H79na9jQ14VzuKD4UPxfG2T0E0fXzsspEmIgfLaBldS24yvkHgE+SDjZhL7Ozd8xfvtH7/i/Nk7VT8+hc62CbpbJ+LqbVVeBokB74tVWoMZ7IrReIo/27pQeXP9977xDUCuXOEQsvde1po+2CrYEuLaYvIeNiOp33CgQ7m35Tw+Ch/H2vwFExAqpMuFD1kpGBYHztJTR6cC/Ubu4KS2ILX4Zgo9UbIiSPUM1u8Ow78Ad+90xDzDcoq9c="
}

# Сегмент пула
variable "az_zone" {
  default = "ru-3b"
}

# Тип сетевого диска, из которого создается сервер
variable "volume_type" {
  default = "fast.ru-3b"
}

# CIDR подсети
variable "subnet_cidr" {
  default = "10.10.0.0/24"
}