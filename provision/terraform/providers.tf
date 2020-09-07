provider "aws" {
    access_key  = var.aws_admin_access_key
    secret_key  = var.aws_admin_secret_key
    region      = var.aws_region
}

provider "aws" {
    alias       = "virginia"
    access_key  = var.aws_admin_access_key
    secret_key  = var.aws_admin_secret_key
    region      = var.aws_region
}

