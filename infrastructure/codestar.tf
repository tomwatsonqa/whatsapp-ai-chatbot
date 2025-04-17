resource "aws_codestarconnections_connection" "_" {
  name          = "${local.project}-codestar"
  provider_type = "GitHub"
}
