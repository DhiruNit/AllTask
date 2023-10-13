# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "myepamtest" {
  name     = "myResourceGroup"
  location = "East US"
}

# Create a public IP address
resource "azurerm_public_ip" "myepamtest" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.myepamtest.location
  resource_group_name = azurerm_resource_group.myepamtest.name
  allocation_method   = "Dynamic"
}

# Create a virtual network
resource "azurerm_virtual_network" "myepamtest" {
  name                = "myVNet"
  location            = azurerm_resource_group.myepamtest.location
  resource_group_name = azurerm_resource_group.myepamtest.name
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet
resource "azurerm_subnet" "myepamtest" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.myepamtest.name
  virtual_network_name = azurerm_virtual_network.myepamtest.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a network interface
resource "azurerm_network_interface" "myepamtest" {
  name                = "myNIC"
  location            = azurerm_resource_group.myepamtest.location
  resource_group_name = azurerm_resource_group.myepamtest.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.myepamtest.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a virtual machine
resource "azurerm_virtual_machine" "myepamtest" {
  name                  = "myVM"
  location              = azurerm_resource_group.myepamtest.location
  resource_group_name   = azurerm_resource_group.myepamtest.name
  network_interface_ids = [azurerm_network_interface.myepamtest.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "myvm"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

