locals {
  admin_username = "azureuser"
  content  = templatefile("${path.root}/customdata.tpl", {
    target_host = var.target_host
    admin_username = "ubuntu"
  })
}
