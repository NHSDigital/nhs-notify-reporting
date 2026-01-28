<!-- BEGIN_TF_DOCS -->
<!-- markdownlint-disable -->
<!-- vale off -->

## Requirements

No requirements.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_ids"></a> [account\_ids](#input\_account\_ids) | All AWS Account IDs for this project | `map(string)` | `{}` | no |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | The name of the AWS Account to deploy into (see globals.tfvars) | `string` | n/a | yes |
| <a name="input_app_deployer_role_name"></a> [app\_deployer\_role\_name](#input\_app\_deployer\_role\_name) | Name of the app deployer role that is allowed to deploy Comms Mgr applications but not create other IAM roles | `string` | n/a | yes |
| <a name="input_app_deployer_role_permission_account_ids"></a> [app\_deployer\_role\_permission\_account\_ids](#input\_app\_deployer\_role\_permission\_account\_ids) | All AWS Account IDs for this project that have the AppDeployer role created | `map(string)` | `{}` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The AWS Account ID (numeric) | `string` | n/a | yes |
| <a name="input_batch_client_ids"></a> [batch\_client\_ids](#input\_batch\_client\_ids) | List of client ids that require additional batch identifier dimensions when aggregating data | `list(string)` | <pre>[<br/>  "NULL"<br/>]</pre> | no |
| <a name="input_cloudtrail_log_group_name"></a> [cloudtrail\_log\_group\_name](#input\_cloudtrail\_log\_group\_name) | The name of the Cloudtrail log group name on the account (see globals.tfvars) | `string` | n/a | yes |
| <a name="input_component"></a> [component](#input\_component) | The name of the component | `string` | `"reporting"` | no |
| <a name="input_continuous_s3backup_retention_days"></a> [continuous\_s3backup\_retention\_days](#input\_continuous\_s3backup\_retention\_days) | number of days to retain continous s3 restore points for PITR - Maximum 35 days | `number` | `31` | no |
| <a name="input_core_account_id"></a> [core\_account\_id](#input\_core\_account\_id) | The core account that contains the corresponding Glue Catalog | `string` | `1234567890` | no |
| <a name="input_core_account_ids"></a> [core\_account\_ids](#input\_core\_account\_ids) | List of all corresponding core account id's that exist in the Non-Prod domain | `list(string)` | `[]` | no |
| <a name="input_core_env"></a> [core\_env](#input\_core\_env) | The core environment that contains the corresponding Glue table/S3 buckets etc. | `string` | `"internal-dev"` | no |
| <a name="input_default_kms_deletion_window_in_days"></a> [default\_kms\_deletion\_window\_in\_days](#input\_default\_kms\_deletion\_window\_in\_days) | Default number of days to set KMS key deletion window | `number` | `14` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | A map of default tags to apply to all taggable resources within the component | `map(string)` | `{}` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The desired number of instances in the Power BI On-Premises Gateway Auto Scaling group. | `number` | `1` | no |
| <a name="input_destination_backup_vault_arn"></a> [destination\_backup\_vault\_arn](#input\_destination\_backup\_vault\_arn) | ARN of the destination backup vault to copy periodic backups to | `string` | `""` | no |
| <a name="input_email_filter_client_ids"></a> [email\_filter\_client\_ids](#input\_email\_filter\_client\_ids) | List of client ids that need email-only sending groups to be hidden in certain views | `list(string)` | <pre>[<br/>  "NULL"<br/>]</pre> | no |
| <a name="input_enable_powerbi_gateway"></a> [enable\_powerbi\_gateway](#input\_enable\_powerbi\_gateway) | Deploy EC2 instance for PowerBI On-Premises Gateway | `bool` | `true` | no |
| <a name="input_enable_s3_backup"></a> [enable\_s3\_backup](#input\_enable\_s3\_backup) | Enable AWS S3 Backup of the data bucket | `bool` | `true` | no |
| <a name="input_enable_spot"></a> [enable\_spot](#input\_enable\_spot) | run Power BI On-Premises Gateway as spot instances | `bool` | `false` | no |
| <a name="input_enable_vault_lock_configuration"></a> [enable\_vault\_lock\_configuration](#input\_enable\_vault\_lock\_configuration) | Enable vault lock, preventing the deletion of a vault that contains 1 or more Recovery Points | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment | `string` | n/a | yes |
| <a name="input_group"></a> [group](#input\_group) | The group variables are being inherited from (often synonmous with account short-name) | `string` | `"n/a"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The EC2 instance type. | `string` | `"t3.medium"` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | How many days to retain the logs generated by the step function | `number` | `30` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum number of instances in the Power BI On-Premises Gateway Auto Scaling group. | `number` | `1` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum number of instances in the Power BI On-Premises Gateway Auto Scaling group. | `number` | `1` | no |
| <a name="input_module"></a> [module](#input\_module) | The variable encapsulating the name of this module | `string` | `"n/a"` | no |
| <a name="input_parent_acct_environment"></a> [parent\_acct\_environment](#input\_parent\_acct\_environment) | Name of the environment responsible for the acct resources used, affects things like DNS zone. Useful for named dev environments | `string` | `"main"` | no |
| <a name="input_periodic_s3backup_copy_retention_days"></a> [periodic\_s3backup\_copy\_retention\_days](#input\_periodic\_s3backup\_copy\_retention\_days) | number of days to retain weekly s3 backups in the destination vault | `number` | `31` | no |
| <a name="input_periodic_s3backup_retention_days"></a> [periodic\_s3backup\_retention\_days](#input\_periodic\_s3backup\_retention\_days) | number of days to retain weekly s3 backups | `number` | `31` | no |
| <a name="input_periodic_s3backup_schedule"></a> [periodic\_s3backup\_schedule](#input\_periodic\_s3backup\_schedule) | Crontab formatted schedule for Periodic S3 Backups | `string` | `"cron(0 5 ? * 7 *)"` | no |
| <a name="input_powerbi_gateway_instance_count"></a> [powerbi\_gateway\_instance\_count](#input\_powerbi\_gateway\_instance\_count) | Number of standalone Power BI On-Premises Gateway instances created directly from the launch template. | `number` | `2` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | List of CIDR blocks for private subnets. | `list(string)` | `[]` | no |
| <a name="input_project"></a> [project](#input\_project) | The name of the Project we are bootstrapping tfscaffold for | `string` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | List of CIDR blocks for public subnets. | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS Region | `string` | n/a | yes |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Size of root volume for the Power BI On-Premises Gateway instances - 30GB minimum for Windows Server | `number` | `80` | no |
| <a name="input_scale_in_recurrence_schedule"></a> [scale\_in\_recurrence\_schedule](#input\_scale\_in\_recurrence\_schedule) | The cron expression for the scale in schedule. Set to null if no recurrence is needed. | `string` | `null` | no |
| <a name="input_scale_out_recurrence_schedule"></a> [scale\_out\_recurrence\_schedule](#input\_scale\_out\_recurrence\_schedule) | The cron expression for the scale out schedule. Set to null if no recurrence is needed. | `string` | `null` | no |
| <a name="input_shared_infra_account_id"></a> [shared\_infra\_account\_id](#input\_shared\_infra\_account\_id) | The AWS Account ID of the shared infrastructure account | `string` | `"000000000000"` | no |
| <a name="input_spot_max_price"></a> [spot\_max\_price](#input\_spot\_max\_price) | max spot price for Power BI On-Premises Gateway instances | `string` | `"0.3"` | no |
| <a name="input_superuser_role_name"></a> [superuser\_role\_name](#input\_superuser\_role\_name) | Name of the superuser role that is allowed to create other IAM roles | `string` | n/a | yes |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_powerbi_gateway_vpc"></a> [powerbi\_gateway\_vpc](#module\_powerbi\_gateway\_vpc) | terraform-aws-modules/vpc/aws | 5.5.1 |
## Outputs

No outputs.
<!-- vale on -->
<!-- markdownlint-enable -->
<!-- END_TF_DOCS -->
