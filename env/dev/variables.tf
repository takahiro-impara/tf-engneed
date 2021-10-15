variable "assume_role" {
  default = "arn:aws:iam::732575084868:role/EngineedExam00111"
}

variable "username" {
  default = "admin"
  sensitive = true
}

variable "password" {
  default = "PassW0rd!"
  sensitive = true
}
