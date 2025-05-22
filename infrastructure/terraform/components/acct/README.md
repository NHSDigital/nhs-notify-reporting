<!-- BEGIN_TF_DOCS -->
<!-- markdownlint-disable -->
<!-- vale off -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.50 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The AWS Account ID (numeric) | `string` | n/a | yes |
| <a name="input_component"></a> [component](#input\_component) | The variable encapsulating the name of this component | `string` | `"acct"` | no |
| <a name="input_core_account_ids"></a> [core\_account\_ids](#input\_core\_account\_ids) | List of core account IDs | `list(string)` | `[]` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | A map of default tags to apply to all taggable resources within the component | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the tfscaffold environment | `string` | n/a | yes |
| <a name="input_group"></a> [group](#input\_group) | The group variables are being inherited from (often synonmous with account short-name) | `string` | n/a | yes |
| <a name="input_oam_sink_id"></a> [oam\_sink\_id](#input\_oam\_sink\_id) | The ID of the Cloudwatch OAM sink in the appropriate observability account. | `string` | `null` | no |
| <a name="input_observability_account_id"></a> [observability\_account\_id](#input\_observability\_account\_id) | The Observability Account ID that needs access | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | The name of the tfscaffold project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS Region | `string` | n/a | yes |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_obs_datasource"></a> [obs\_datasource](#module\_obs\_datasource) | git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/obs-datasource | v2.0.3 |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_account_id"></a> [aws\_account\_id](#output\_aws\_account\_id) | n/a |
| <a name="output_log_subscription_role_arn"></a> [log\_subscription\_role\_arn](#output\_log\_subscription\_role\_arn) | n/a |
<!-- vale on -->
<!-- markdownlint-enable -->
<!-- END_TF_DOCS -->
