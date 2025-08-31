variable "inst_types" {
    description = "list of instance types to use eks cluster"
    type = map(string)
    default = {
        dev = "t2.micro"
        prod = "t2.medium"

    }
}

variable "cidrb" {
    type = string
    default = "10.0.0.0/16"
}

variable "region" {
    default = "us-east-1"
}