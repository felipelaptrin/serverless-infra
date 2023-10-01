<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.17.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.17.0 |
| <a name="provider_aws.virginia"></a> [aws.virginia](#provider\_aws.virginia) | 5.17.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_api_gateway_base_path_mapping.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_base_path_mapping) | resource |
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_domain_name.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_domain_name) | resource |
| [aws_api_gateway_integration.any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_method.any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_resource.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_policy.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_lambda_function.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.apig_to_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_route53_record.root_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_security_group.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region to deploy the resources. | `string` | `"us-east-1"` | no |
| <a name="input_backend_api_gateway_name"></a> [backend\_api\_gateway\_name](#input\_backend\_api\_gateway\_name) | Name of the API Gateway to create | `string` | n/a | yes |
| <a name="input_backend_lambda_architecture"></a> [backend\_lambda\_architecture](#input\_backend\_lambda\_architecture) | Architecture used to run the code. It accepts the following values: x86\_64 or arm64. Keep in mind that the arm64 is cheaper than x86\_64 | `string` | `"arm64"` | no |
| <a name="input_backend_lambda_environments_variables"></a> [backend\_lambda\_environments\_variables](#input\_backend\_lambda\_environments\_variables) | A key-value pair corresponding to the environment variables that the function needs to run. | `map(string)` | `{}` | no |
| <a name="input_backend_lambda_handler"></a> [backend\_lambda\_handler](#input\_backend\_lambda\_handler) | Function entrypoint in your code | `string` | `"index.handler"` | no |
| <a name="input_backend_lambda_memory_in_MB"></a> [backend\_lambda\_memory\_in\_MB](#input\_backend\_lambda\_memory\_in\_MB) | Amount of memory in MB that your Lambda Function will use. Remember that you do not configure CPU in a Lambda, if you need more CPU, please you need to increase the Memory since CPU scale with memory in Lambda. | `number` | `128` | no |
| <a name="input_backend_lambda_name"></a> [backend\_lambda\_name](#input\_backend\_lambda\_name) | Name of the AWS Lambda that will run the backend code | `string` | n/a | yes |
| <a name="input_backend_lambda_runtime"></a> [backend\_lambda\_runtime](#input\_backend\_lambda\_runtime) | Function's runtime. You can check available values in https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#API_CreateFunction_RequestSyntax | `string` | `"nodejs16.x"` | no |
| <a name="input_backend_lambda_s3_object"></a> [backend\_lambda\_s3\_object](#input\_backend\_lambda\_s3\_object) | Name of the zipped code object in the 'backend\_s3\_bucket\_name' bucket | `string` | n/a | yes |
| <a name="input_backend_lambda_timeout_in_seconds"></a> [backend\_lambda\_timeout\_in\_seconds](#input\_backend\_lambda\_timeout\_in\_seconds) | Maximum amount of time that the Lambda has to return a response. | `number` | `3` | no |
| <a name="input_backend_s3_bucket_name"></a> [backend\_s3\_bucket\_name](#input\_backend\_s3\_bucket\_name) | Name of the S3 bucket that will store the code of the AWS Lambda. This bucket will be populated by the CI of the backend repository | `string` | n/a | yes |
| <a name="input_backend_s3_bucket_name_application"></a> [backend\_s3\_bucket\_name\_application](#input\_backend\_s3\_bucket\_name\_application) | Name of the S3 bucket that the backend will store data. | `string` | n/a | yes |
| <a name="input_backend_subdomain"></a> [backend\_subdomain](#input\_backend\_subdomain) | Name of the subdomain of the backend application. This means that if you se this value as 'api' and your domain is 'games.com', the FQDN will be 'api.games.com' | `string` | n/a | yes |
| <a name="input_database_engine"></a> [database\_engine](#input\_database\_engine) | The version of the engine | `string` | `"mysql"` | no |
| <a name="input_database_engine_version"></a> [database\_engine\_version](#input\_database\_engine\_version) | The version of the engine that you are going to use. You can specify only the major and minor versions. Use the AWS CLI in order to get all engine versions available `aws rds aws rds describe-db-engine-versions --engine mysql` | `string` | n/a | yes |
| <a name="input_database_identifier"></a> [database\_identifier](#input\_database\_identifier) | The name of the RDS instance that will be created. In other words, defines the name that will appear in the AWS console. | `string` | n/a | yes |
| <a name="input_database_instance_class"></a> [database\_instance\_class](#input\_database\_instance\_class) | Name of the instance class used to run the database. You can check all the available instances and compare all of them using https://instances.vantage.sh/rds/ | `string` | n/a | yes |
| <a name="input_database_master_username"></a> [database\_master\_username](#input\_database\_master\_username) | Name of the master username of the database | `string` | `"root"` | no |
| <a name="input_database_max_storage_in_GiB"></a> [database\_max\_storage\_in\_GiB](#input\_database\_max\_storage\_in\_GiB) | Maximium storage size that the storage can scale in gibibytes (GiB). If not set or set to zero, the autoscaling of the storage will be disabled | `number` | `0` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | The name of the database to create when the DB instance is created. | `string` | n/a | yes |
| <a name="input_database_password"></a> [database\_password](#input\_database\_password) | Password of the database | `string` | n/a | yes |
| <a name="input_database_port"></a> [database\_port](#input\_database\_port) | The port on which the DB accepts connections. | `number` | `3306` | no |
| <a name="input_database_requested_storage_in_GiB"></a> [database\_requested\_storage\_in\_GiB](#input\_database\_requested\_storage\_in\_GiB) | The allocated storage in gibibytes (GiB). | `number` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name of the application (e.g. mydomain.net) | `string` | n/a | yes |
| <a name="input_frontend_bucket_name"></a> [frontend\_bucket\_name](#input\_frontend\_bucket\_name) | The name of the bucket that is gonna host the frontend website content | `string` | n/a | yes |
| <a name="input_frontend_subdomain"></a> [frontend\_subdomain](#input\_frontend\_subdomain) | Name of the subdomain of the frontend application. This means that if you se this value as 'app' and your domain is 'games.com', the FQDN will be 'app.games.com' | `string` | n/a | yes |
| <a name="input_network_ip"></a> [network\_ip](#input\_network\_ip) | CIDR block of the VPC network | `string` | `"10.100.0.0"` | no |
| <a name="input_website_entry_document"></a> [website\_entry\_document](#input\_website\_entry\_document) | Name of the entrypoint of the website | `string` | `"index.html"` | no |
| <a name="input_website_error_document"></a> [website\_error\_document](#input\_website\_error\_document) | Name of the file that contains a user-friendly error message | `string` | `"index.html"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->