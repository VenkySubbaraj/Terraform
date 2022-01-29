variable "vmname" {
  
    #description = "Create Webapp with following names"
    type        = list(string)
    default     = ["webapp-a", "webapp-b", "webapp-c"]
}
variable "nwinter" {
  
    #description = "Create Webapp with following names"
    type        = list(string)
    default     = ["nic1", "nic2", "nic3"]
}
variable "public_ip" {
  
    description = "Create Webapp with following names"
    type        = list(string)
    default     = ["public1", "public2", "public3"]
}
