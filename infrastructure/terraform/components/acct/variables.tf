##
# Basic Required Variables for tfscaffold Components
##

variable "project" {
  type        = string
  description = "The name of the tfscaffold project"
}

variable "environment" {
  type        = string
  description = "The name of the tfscaffold environment"
}

variable "aws_account_id" {
  type        = string
  description = "The AWS Account ID (numeric)"
}

variable "region" {
  type        = string
  description = "The AWS Region"
}

variable "group" {
  type        = string
  description = "The group variables are being inherited from (often synonmous with account short-name)"
}

##
# tfscaffold variables specific to this component
##

# This is the only primary variable to have its value defined as
# a default within its declaration in this file, because the variables
# purpose is as an identifier unique to this component, rather
# then to the environment from where all other variables come.
variable "component" {
  type        = string
  description = "The variable encapsulating the name of this component"
  default     = "acct"
}

variable "default_tags" {
  type        = map(string)
  description = "A map of default tags to apply to all taggable resources within the component"
  default     = {}
}

##
# Variables specific to the "acct" component
##

variable "core_account_ids" {
  type        = list(string)
  description = "List of core account IDs"
  default     = []
}

variable "observability_account_id" {
  type        = string
  description = "The Observability Account ID that needs access"
  default     = null
}

variable "oam_sink_id" {
  description = "The ID of the Cloudwatch OAM sink in the appropriate observability account."
  type        = string
  default     = null
}

variable "cost_alarm_recipients" {
  type        = list(string)
  description = "A list of email addresses to receive alarm notifications"
  default     = []
}

variable "budget_amount" {
  type        = number
  description = "The budget amount in USD for the account"
  default     = 500
}

variable "cost_anomaly_threshold" {
  type        = number
  description = "The threshold percentage for cost anomaly detection"
  default     = 10
}

variable "kms_deletion_window" {
  type        = string
  description = "When a kms key is deleted, how long should it wait in the pending deletion state?"
  default     = "30"
}
