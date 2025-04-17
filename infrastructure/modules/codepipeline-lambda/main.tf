data "aws_s3_bucket" "codepipeline" {
  bucket = var.codepipeline_bucket_name
}

data "aws_s3_bucket" "lambda" {
  bucket = var.lambda_bucket_name
}

data "aws_lambda_function" "_" {
  function_name = var.name
}

data "aws_iam_policy_document" "assume" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "_" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "send_message_policy_document" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:PutObjectAcl",
      "s3:DeleteObject"
    ]
    resources = [
      data.aws_s3_bucket.codepipeline.arn,
      "${data.aws_s3_bucket.codepipeline.arn}/*",
      data.aws_s3_bucket.lambda.arn,
      "${data.aws_s3_bucket.lambda.arn}/*"
    ]
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = ["*"]
  }

  statement {
    actions   = ["codestar-connections:*"]
    resources = [var.codestar_connection_arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "_" {
  name   = "${var.name}-role-policy"
  role   = aws_iam_role._.id
  policy = data.aws_iam_policy_document.send_message_policy_document.json
}

resource "aws_codebuild_project" "buildspec" {
  name           = "${var.name}-build"
  description    = "Buildspec"
  build_timeout  = "20"
  queued_timeout = "5"

  service_role = aws_iam_role._.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_path
  }
}

resource "aws_codebuild_project" "update_lambda" {
  name           = "${var.name}-update-lambda"
  description    = "Update lambda"
  build_timeout  = "5"
  queued_timeout = "5"

  service_role = aws_iam_role._.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "NO_SOURCE"
    buildspec = <<EOF
      version: 0.2

      phases:
        build:
          commands:
              aws lambda update-function-code --function-name $FUNCTION_NAME --s3-bucket $BUCKET --s3-key $KEY

    EOF
  }
}

resource "aws_codepipeline" "_" {
  name          = var.name
  pipeline_type = "V2"
  role_arn      = aws_iam_role._.arn

  artifact_store {
    location = data.aws_s3_bucket.codepipeline.id
    type     = "S3"
  }

  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      source_action_name = "Source"
      push {
        file_paths {
          includes = var.file_paths
        }
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn : var.codestar_connection_arn
        FullRepositoryId : var.repository_id
        BranchName : var.branch_name
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.buildspec.name
      }
    }
  }

  stage {
    name = "Deploy-S3"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        BucketName = data.aws_s3_bucket.lambda.id
        Extract    = false
        ObjectKey  = var.name
        CannedACL  = "private"
      }
    }
  }

  stage {
    name = "Update-Lambda"

    action {
      name            = "Update-Lambda"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.update_lambda.name
        EnvironmentVariables = jsonencode([
          {
            name  = "FUNCTION_NAME"
            value = var.name
          },
          {
            name  = "BUCKET"
            value = data.aws_s3_bucket.lambda.id
          },
          {
            name  = "KEY"
            value = var.name
          }
        ])
      }
    }
  }
}
