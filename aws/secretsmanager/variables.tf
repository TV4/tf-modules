variable "kms_key" {
  description = "Key value for generating KMS key and prefix for secrets"
  type        = string
}

variable "secretsmanager_entries" {
  description = "List of secret entries"
  type        = list(string)
}

variable "accounts" {
  description = "List of AWS account ids which should get access to KMS key and associated secrets"
  type        = list(string)
}

variable "tags" {
  description = "Custom tags to add"
  type        = map(any)
}
