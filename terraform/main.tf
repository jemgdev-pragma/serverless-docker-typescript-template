module "ecr" {
  source      = "./modules/ecr"
  repo_name   = "template-image-${var.stage}"
}

module "security_group" {
  source      = "./modules/security-group"
  vpc_id      = var.vpc_id
  port        = var.port
  expose_port = var.expose_port
}

module "ecs" {
  source            = "./modules/ecs"
  stage             = var.stage
  subnet_id         = var.subnet_id
  security_group_id = module.security_group.security_group_id
  repo_url          = module.ecr.repository_url
  port              = var.port
  expose_port       = var.expose_port
}
