variable "df_region"                {}
variable "access_key"               {}
variable "secret_key"               {}

#Variables for networking
variable "df_cidr_block_anywhere"   {}
variable "vpc_cidr_block"           {}
variable "subnet_cidr_block_a"      {}
variable "subnet_cidr_block_b"      {}
variable "availability_zone_a"      {}
variable "availability_zone_b"      {}
variable "public_ip"                {}

#Variables for instances
variable "ec2_ami_id"               {}
variable "ec2_instance_type"        {}
variable "key_name"                 {}

#IAM roles for instances
variable "access_level"             {default = "ec2_full_access_role"}
variable "ver"                      {default = "2012-10-17"}
variable "action"                   {default = "sts:AssumeRole"}
variable "effect"                   {default = "Allow"}
variable "principal_service"        {default = "ec2.amazonaws.com"}
variable "policy_arn"               {default = "arn:aws:iam::aws:policy/AdministratorAccess"}
variable "instance_profile_name"    {default = "ec2_full_access_profile"}
variable "machine_role"             {default = "dp5_machine_role"}

#Variables for instance tags
variable "ec2_instance_tag_1" {
  description = "tag for first instance"
  type        = map(string)
}

variable "ec2_instance_tag_2" {
  description = "tag for second instance"
  type        = map(string)
}

variable "ec2_instance_tag_3" {
  description = "tag for third instance"
  type        = map(string)
}


variable "ud_jenkins" {
  description = "path to jenkins with python script"
  default     = "user_data_5.1_jenkins.sh"
}

variable "ud_py_java" {
  description = "path to python script"
  default     = "user_data_5.1_java_python.sh"
}

# Variables for ingress traffic
variable "ssh_access" {
  description = "access through SSH on PORT 22"
  type = object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })
  default = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "http_access" {
  type = object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })
  default = {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "jenkins_access" {
  description = "access jenkins on PORT 8080"
  type = object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })
  default = {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Variables for egress traffic
variable "outgoing" {
  type = object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })
  default = {
    from_port   = 0
    to_port     = 65000
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
