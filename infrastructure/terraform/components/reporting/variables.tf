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

variable "core_env" {
  type        = string
  description = "The core environment that contains the corresponding Glue table/S3 buckets etc."
  default     = "internal-dev"
}

variable "log_retention_days" {
  type        = number
  description = "How many days to retain the logs generated by the step function"
  default     = 30
}

variable "enable_powerbi_gateway" {
  type        = bool
  description = "Deploy EC2 instance for PowerBI On-Premises Gateway"
  default     = true
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "The desired number of instances in the Power BI On-Premises Gateway Auto Scaling group."
  type        = number
  default     = 1
}

variable "min_size" {
  description = "The minimum number of instances in the Power BI On-Premises Gateway Auto Scaling group."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of instances in the Power BI On-Premises Gateway Auto Scaling group."
  type        = number
  default     = 1
}

variable "enable_spot" {
  type        = bool
  description = "run Power BI On-Premises Gateway as spot instances"
  default     = false
}

variable "spot_max_price" {
  type        = string
  description = "max spot price for Power BI On-Premises Gateway instances"
  default     = "0.3"
}

variable "root_volume_size" {
  type        = number
  description = "Size of root volume for the Power BI On-Premises Gateway instances - 30GB minimum for Windows Server"
  default     = 30
}

variable "scale_out_recurrence_schedule" {
  description = "The cron expression for the scale out schedule. Set to null if no recurrence is needed."
  type        = string
  default     = null
}

variable "scale_in_recurrence_schedule" {
  description = "The cron expression for the scale in schedule. Set to null if no recurrence is needed."
  type        = string
  default     = null
}

variable "core_account_ids" {
  description = "List of all corresponding core account id's that exist in the Non-Prod domain"
  type = list(string)
  default = []
}

variable "batch_client_ids" {
  description = "List of client ids that require additional batch identifier dimensions when aggregating data"
  type = list(string)
  default = ["NULL"]
}

variable "enable_s3_backup" {
  type        = bool
  description = "Enable AWS S3 Backup of data and results buckets"
  default     = true
}

variable "continuous_s3backup_retention_days" {
  type        = number
  description = "number of days to retain continous s3 backups for PITR"
  default     = 35
}

variable "periodic_s3backup_retention_days" {
  type        = number
  description = "number of days to retain weekly s3 backups"
  default     = 365
}

variable "periodic_s3backup_schedule" {
  type        = string
  description = "Crontab formatted schedule for Periodic S3 Backups"
  default     = "cron(0 5 ? * 7 *)" # Runs every Saturday at 5 AM UTC
}

variable "enable_vault_lock_configuration" {
  type        = bool
  description = "Enable vault lock, preventing the deletion of a vault that contains 1 or more Recovery Points"
  default     = false
}
