provider   "azurerm"   {
   features   {} 
 } 

 resource   "azurerm_resource_group"   "rg"   { 
   name   =   "my-first-terraform-rg" 
   location   =   "centralindia" 
 } 

 resource   "azurerm_virtual_network"   "myvnet"   { 
   name   =   "my-vnet" 
   address_space   =   [ "10.0.0.0/16" ] 
   location   =   "centralindia" 
   resource_group_name   =   azurerm_resource_group.rg.name 
 } 

 resource   "azurerm_subnet"   "frontendsubnet"   { 
   name   =   "frontendSubnet" 
   resource_group_name   =    azurerm_resource_group.rg.name 
   virtual_network_name   =   azurerm_virtual_network.myvnet.name 
   address_prefix   =   "10.0.1.0/24"  
 } 

 resource   "azurerm_public_ip"   "myvmpublicip"   { 
   count = 3
   name   =   var.public_ip[count.index] 
   location   =   "centralindia" 
   resource_group_name   =   azurerm_resource_group.rg.name 
   allocation_method   =   "Dynamic" 
   sku   =   "Basic" 
 } 

 resource   "azurerm_network_interface"   "myvmnic"   {
   count = 3
   name   =   var.nwinter[count.index] 
   location   =   "centralindia" 
   resource_group_name   =   azurerm_resource_group.rg.name 

   ip_configuration   { 
     name   =   "ipconfig1" 
     subnet_id   =   azurerm_subnet.frontendsubnet.id 
     private_ip_address_allocation   =   "Dynamic" 
     public_ip_address_id   =   azurerm_public_ip.myvmpublicip[count.index].id 
   } 
 } 

 resource   "azurerm_linux_virtual_machine"   "terraformrg"  { 
   name                    =   var.vmname[count.index]   
   count = 3
   location                =   "centralindia" 
   resource_group_name     =   azurerm_resource_group.rg.name 
   network_interface_ids   =   [ azurerm_network_interface.myvmnic[count.index].id ] 
   size                    =   "Standard_B1s" 
   admin_username          =   "adminuser" 
   admin_password          =   "Password123!" 

   source_image_reference   { 
     publisher   =   "canonical" 
     offer       =   "0001-com-ubuntu-server-focal" 
     sku         =   "20_04-lts-gen2" 
     version     =   "latest" 
   } 

   os_disk   { 
     caching             =   "ReadWrite" 
     storage_account_type   =   "Standard_LRS" 
   }
   disable_password_authentication = false
 }
