variable "inbound_fromport" {
    default = [0,8,8443,22,0]
}
variable "inbound_toport" {
    default = [65535,0,8443,22,65535]
}

variable "outbound_rule_fromport" {
    default = [0]
}

variable "outbound_rule_toport" {
    default = [0]
}

variable "protocol" {
  default = ["udp","icmp","tcp","tcp","tcp"]
}

variable "security_group_name"{
  default = "Master_Instance"
}



