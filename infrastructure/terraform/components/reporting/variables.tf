variable "project" {
  type        = string
  description = "The name of the Project we are bootstrapping tfscaffold for"
}

variable "account_ids" {
  type        = map(string)
  description = "All AWS Account IDs for this project"
  default     = {}
}

variable "account_name" {
  type        = string
  description = "The name of the AWS Account to deploy into (see globals.tfvars)"
}

variable "app_deployer_role_permission_account_ids" {
  type        = map(string)
  description = "All AWS Account IDs for this project that have the AppDeployer role created"
  default     = {}
}

variable "superuser_role_name" {
  type        = string
  description = "Name of the superuser role that is allowed to create other IAM roles"
}

variable "app_deployer_role_name" {
  type        = string
  description = "Name of the app deployer role that is allowed to deploy Comms Mgr applications but not create other IAM roles"
}
variable "region" {
  type        = string
  description = "The AWS Region"
}

variable "environment" {
  type        = string
  description = "The name of the environment"
}

variable "component" {
  type        = string
  description = "The name of the component"
  default     = "reporting"
}

variable "group" {
  type        = string
  description = "The group variables are being inherited from (often synonmous with account short-name)"
  default     = "n/a"
}

variable "cloudtrail_log_group_name" {
  type        = string
  description = "The name of the Cloudtrail log group name on the account (see globals.tfvars)"
}

variable "module" {
  type        = string
  description = "The variable encapsulating the name of this module"
  default     = "n/a"
}

variable "default_kms_deletion_window_in_days" {
  type        = number
  description = "Default number of days to set KMS key deletion window"
  default     = 14
}

variable "core_account_id" {
  type        = string
  description = "The core account that contains the corresponding Glue Catalog"
  default     = 1234567890
}
