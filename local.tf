# Define Local Values in Terraform
locals {
  owners       = var.business_divsion
  project-team = var.project-team
  name         = "${var.business_divsion}-${var.project-team}"
  common_tags = {
    owners = local.owners
  }
}
