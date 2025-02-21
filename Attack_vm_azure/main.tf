# Resource Group
resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "${var.name_prefix}-rg"
}

# Virtual Network
resource "azurerm_virtual_network" "defend_attack_vm_network" {
  name                = "${var.name_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet 1
resource "azurerm_subnet" "defend_attack_vm_subnet_1" {
  name                 = "${var.name_prefix}-subnet-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.defend_attack_vm_network.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Create a Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name_prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Allow SSH Access
resource "azurerm_network_security_rule" "ssh_rule" {
  name                        = "AllowSSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name = azurerm_resource_group.rg.name
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.defend_attack_vm_subnet_1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create a Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.name_prefix}-pub-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create a Network Interface (NIC)
resource "azurerm_network_interface" "nic" {
  name                = "${var.name_prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.name_prefix}-nic-config"
    subnet_id                     = azurerm_subnet.defend_attack_vm_subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# 8. Create a Virtual Machine (VM)
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.name_prefix}-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B1s"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  provisioner "file" {
    source = "~/.ssh/test_key"
    destination = "/home/azureuser/aws_ec2_key"

    connection {
      type     = "ssh"
      user     = "azureuser"
      private_key = file("~/.ssh/test_key")
      host     = azurerm_linux_virtual_machine.vm.public_ip_address
    }
  }

  admin_username = local.admin_username
  custom_data = base64encode(local.content)
  admin_ssh_key {
    public_key = file("~/.ssh/test_key.pub")
    username   = "azureuser"
  }
}


