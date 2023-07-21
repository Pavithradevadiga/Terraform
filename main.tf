provider "aws" {
    region = "us-east-1"
}


resource "aws_iam_role" "lambda_role" {
    name = "HolidayManagement_Role"
    assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  description = "AWS IAM Policy for managing AWS Lambda role"
  path        = "/"
  policy      = <<EOF
{
  "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": "arn:aws:logs:*:*:*",
                "Effect": "Allow"
            },{
                "Action": [
                    "dynamodb:*"
                ],
                "Resource": "arn:aws:dynamodb:*:*:*",
                "Effect": "Allow"
            }
        ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role1"{
    role = aws_iam_role.lambda_role.name
    policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role2"{
    role = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "zip_the_python_code"{
    type = "zip"
    source_dir = "${path.module}/lambdafunction/"
    output_path = "${path.module}/lambdafunction/hello-python.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
    filename = "${path.module}/lambdafunction/hello-python.zip"
    function_name = "terraformfunction"
    role = aws_iam_role.lambda_role.arn
    handler = "index.lambda_handler"
    runtime = "python3.9"
    depends_on = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role1,aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role2]
    environment {
        variables = {
        FLAG = "false"
        }
   }
}