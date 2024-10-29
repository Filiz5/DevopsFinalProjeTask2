variable "myami" {
  type = map(string)
  default = {
    dev =  "ami-06b21ccaeff8cd686"
    prod  = "ami-0ddc798b3f1a5117e"
    test   = "ami-06b21ccaeff8cd686"
    staging   = "ami-06b21ccaeff8cd686"
  }
  description = "in order of Amazon Linux 2023 ami, Red Hat Enterprise Linux 8 ami and Ubuntu Server 20.04 LTS"
}

variable "ports" {
  type = map(list(number))
  default = {
    default = [80, 443, 22]
    dev= [80, 443, 22, 5432, 3000, 5000, 3306]
    test= [80, 443, 22, 8080]
    prod= [22, 80, 443, 8080, 9000]
    staging= [22, 80, 443, 8080, 9000]
  }
}

variable "region" {
  default = "us-east-1"  
}


variable "ec2_type" {
  default = "t2.micro"
}
variable "ec2_key" {
  default = "Meliskey" # change here
}

variable "num_of_instance" {
  default = 1
}