variable "aws_region" {
  default = "us-east-1"
}

variable default_keypair_name {
  description = "Name of the KeyPair used for all nodes"
  default     = "Opsschool-1"
}

variable instance_type {
  default = "t2.micro"
}

variable spree_servers {
  default = "1"
}

variable owner {
  default = "Spree"
}

variable vpc_id {
  default = "vpc-584d6e20"
}

variable image {
  type        = "map"
  description = "Cassandra AWS AMI"

  default = {
    "name"     = "spree"
    "tagowner" = "Opsschool"
    "tagname"  = "Spree"
  }
}
