variable "my_ami" {
  default = "ami-02d26659fd82cf299"
}

variable "my_instance" {
  default = "t2.micro"
}

variable "my_key" {
    default = "terraform"
}

variable "user_data" {
  description = "Path to the user_data file"
}