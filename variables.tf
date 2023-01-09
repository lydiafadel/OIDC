variable "create_tfc_oidc_provider" {
  description = "URL"
  type        = string
  default     = "https://app.terraform.io"
}

variable "aud_value" {
  type        = string
  default     = "aws.workload.identity"
  description = " "
}
