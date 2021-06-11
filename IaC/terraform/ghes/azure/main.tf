# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "8d34f04f-62f1-4f1e-b1bf-228fc1e3081b"
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "ghes-group" {
  name     = "${var.stack_name}-ghesResourceGroup"
  location = "eastus"

  tags = {
    environment = "Terraform GHES Demo"
  }
}

# Create virtual network
resource "azurerm_virtual_network" "ghes-network" {
  name                = "${var.stack_name}-ghesVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.ghes-group.name

  tags = {
    environment = "Terraform GHES Demo"
  }
}

# Create subnet
resource "azurerm_subnet" "ghes-subnet" {
  name                 = "${var.stack_name}-ghesSubnet"
  resource_group_name  = azurerm_resource_group.ghes-group.name
  virtual_network_name = azurerm_virtual_network.ghes-network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "ghes-publicip" {
  name                = "${var.stack_name}-ghesPublicIP"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.ghes-group.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "Terraform GHES Demo"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "ghes-nsg" {
  name                = "${var.stack_name}-ghesNetworkSecurityGroup"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.ghes-group.name

  tags = {
    environment = "Terraform GHES Demo"
  }
}

resource "azurerm_network_security_rule" "rule1" {
  name                        = "GHES-GIT-SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ghes-group.name
  network_security_group_name = azurerm_network_security_group.ghes-nsg.name
}

resource "azurerm_network_security_rule" "rule2" {
  name                        = "GHES-HTTP"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ghes-group.name
  network_security_group_name = azurerm_network_security_group.ghes-nsg.name
}

resource "azurerm_network_security_rule" "rule3" {
  name                        = "GHES-HTTPS"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ghes-group.name
  network_security_group_name = azurerm_network_security_group.ghes-nsg.name

}

resource "azurerm_network_security_rule" "rule4" {
  name                        = "GHES-ADMIN"
  priority                    = 1004
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ghes-group.name
  network_security_group_name = azurerm_network_security_group.ghes-nsg.name
}

resource "azurerm_network_security_rule" "rule5" {
  name                        = "GHES-HTTP2"
  priority                    = 1005
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ghes-group.name
  network_security_group_name = azurerm_network_security_group.ghes-nsg.name
}

resource "azurerm_network_security_rule" "rule6" {
  name                        = "GHES-GIT"
  priority                    = 1006
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9418"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ghes-group.name
  network_security_group_name = azurerm_network_security_group.ghes-nsg.name
}

resource "azurerm_network_security_rule" "rule7" {
  name                        = "GHES-ADMIN-SSH"
  priority                    = 1007
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "122"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ghes-group.name
  network_security_group_name = azurerm_network_security_group.ghes-nsg.name
}

# Create network interface
resource "azurerm_network_interface" "ghes-nic" {
  name                = "${var.stack_name}-ghesNIC"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.ghes-group.name

  ip_configuration {
    name                          = "ghesNicConfiguration"
    subnet_id                     = azurerm_subnet.ghes-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ghes-publicip.id
  }

  tags = {
    environment = "Terraform GHES Demo"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "ghes" {
  network_interface_id      = azurerm_network_interface.ghes-nic.id
  network_security_group_id = azurerm_network_security_group.ghes-nsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.ghes-group.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "ghes-storageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.ghes-group.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Terraform GHES Demo"
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "ghes_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "ghes-vm" {
  name                  = "${var.stack_name}-GHES-VM-v${var.ghes_version}"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.ghes-group.name
  network_interface_ids = [azurerm_network_interface.ghes-nic.id]
  size                  = "Standard_DS13_v2" # CPU:8  	MEM (GB):56

  os_disk {
    name                 = "${var.stack_name}-ghesOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "GitHub"
    offer     = "GitHub-Enterprise"
    sku       = "GitHub-Enterprise"
    version   = var.ghes_version
  }

  computer_name                   = "GHES-VM-v${var.ghes_version}"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.ghes-storageaccount.primary_blob_endpoint
  }

  tags = {
    environment = "Terraform GHES Demo"
  }
}

resource "azurerm_managed_disk" "ghes" {
  name                 = "${var.stack_name}-ghes-data-disk"
  location             = azurerm_resource_group.ghes-group.location
  resource_group_name  = azurerm_resource_group.ghes-group.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "ghes" {
  managed_disk_id    = azurerm_managed_disk.ghes.id
  virtual_machine_id = azurerm_linux_virtual_machine.ghes-vm.id
  lun                = "10"
  caching            = "ReadWrite"
}

output "resource_group_name" {
    value = azurerm_resource_group.ghes-group.name
}

output "resource_group_location" {
    value = azurerm_resource_group.ghes-group.location
}

output "tls_private_key" {
  value     = tls_private_key.ghes_ssh.private_key_pem
  sensitive = true
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.ghes-vm.public_ip_address
}
