resource "aws_cloudformation_stack" "outputs" {
  name = var.name

  template_body = local.template_outputs
}

resource "aws_cloudformation_stack" "parameters" {
  name = "${var.name}-params"

  template_body = local.template_parameters
}

variable "name" {
  type    = string
  default = "aws-cfn-using-outputs-from-terraform-outputs"
}