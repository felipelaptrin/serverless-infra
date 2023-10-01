#################
## STORAGE
#################
resource "aws_s3_bucket" "lambda" {
  bucket = var.backend_s3_bucket_name
}

resource "aws_s3_bucket" "backend" {
  bucket = var.backend_s3_bucket_name_application
}

#################
## LAMBDA
#################
resource "aws_security_group" "lambda" {
  name   = "allow_labda_traffic"
  vpc_id = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_policy" "lambda" {
  name        = var.backend_lambda_name
  description = "IAM policy that allows a Lambda with the same name to work properly"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:Put*"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.backend.arn,
          "${aws_s3_bucket.backend.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role" "lambda" {
  name        = var.backend_lambda_name
  description = "IAM Role used by the AWS Lambda with the same name"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",     # Allow logging in CloudWatch
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", # Allow Lambda attached to VPC
    aws_iam_policy.lambda.arn
  ]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowLambdaAssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_lambda_function" "backend" {
  depends_on = [aws_s3_bucket.lambda]

  function_name = var.backend_lambda_name
  role          = aws_iam_role.lambda.arn
  architectures = [var.backend_lambda_architecture]
  handler       = var.backend_lambda_handler
  memory_size   = var.backend_lambda_memory_in_MB
  runtime       = var.backend_lambda_runtime
  timeout       = var.backend_lambda_timeout_in_seconds

  s3_bucket = var.backend_s3_bucket_name
  s3_key    = var.backend_lambda_s3_object

  vpc_config {
    security_group_ids = [aws_security_group.lambda.id]
    subnet_ids = [
      aws_subnet.private[0].id,
      aws_subnet.private[1].id,
      aws_subnet.private[2].id,
    ]
  }

  environment {
    variables = merge(
      var.backend_lambda_environments_variables,
      {
        "DB_HOST" : "ABC" #aws_db_instance.this.address
      }
    )
  }
}

resource "aws_lambda_permission" "apig_to_lambda" {
  depends_on = [
    aws_lambda_function.backend,
    aws_api_gateway_rest_api.this
  ]

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.backend_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${local.account_id}:${aws_api_gateway_rest_api.this.id}/*/*/*"
}

##################
### API GATEWAY
##################

resource "aws_api_gateway_rest_api" "this" {
  name        = var.backend_api_gateway_name
  description = "API Gateway that exposes the API deployed in a lambda"
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "any" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "cors" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "cors" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.cors.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration" "any" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.any.http_method
  integration_http_method = "POST"

  type = "AWS_PROXY"
  uri  = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${local.account_id}:function:${var.backend_lambda_name}/invocations"
}

resource "aws_api_gateway_integration" "cors" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.cors.http_method
  integration_http_method = "OPTIONS"

  type = "AWS_PROXY"
  uri  = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${local.account_id}:function:${var.backend_lambda_name}/invocations"
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "prod"
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.any,
    aws_api_gateway_integration.cors
  ]
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.this.id,
      aws_api_gateway_method.any.id,
      aws_api_gateway_method.cors.id,
      aws_api_gateway_integration.any.id,
      aws_api_gateway_integration.cors.id,
    ]))
  }
}

##################
### ROUTE 53 AND ACM
##################
resource "aws_acm_certificate" "backend" {
  provider = aws.virginia # This certificate MUST be created in us-east-1. Reference: https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-custom-domains.html

  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_domain_name" "this" {
  certificate_arn = aws_acm_certificate.backend.arn
  domain_name     = local.backend_fqdn
}

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.this.domain_name
}

resource "aws_route53_record" "root_domain" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = aws_api_gateway_domain_name.this.domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.this.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.this.cloudfront_zone_id
    evaluate_target_health = false
  }
}
