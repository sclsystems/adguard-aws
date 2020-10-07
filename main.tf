module "adguard" {
  source = "./modules/adguard"

  domain_name              = var.domain_name
  instance_type            = var.instance_type
  allowed_client           = var.allowed_client
  subnet_list              = var.subnet_list
  vpc_id                   = var.vpc_id
  admin_password_hash      = var.admin_password_hash
  alternative_domain_names = var.alternative_domain_names
}
