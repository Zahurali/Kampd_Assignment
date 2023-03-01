resource "aws_codedeploy_app" "web_app" {
  name = "web-app"
}

resource "aws_sns_topic" "app" {
  name = "app-topic"
}


resource "aws_codedeploy_deployment_group" "web_app_deployment" {
  app_name = aws_codedeploy_app.web_app.name
  deployment_group_name = "web_app_group"
  service_role_arn = aws_iam_role.codepipeline_role.arn
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type = "BLUE_GREEN"
  }
  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
  }
   trigger_configuration {
    trigger_events     = ["DeploymentFailure"]
    trigger_name       = "app-trigger"
    trigger_target_arn = aws_sns_topic.app.arn
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  alarm_configuration {
    alarms  = ["my-alarm-name"]
    enabled = true
  }
}
resource "aws_codepipeline" "web_app_pipeline" {
  name = "web-app-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type = "S3"
  }
  stage {
    name = "Source"
    action {
      name = "SourceAction"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      output_artifacts = ["source"]
      configuration = {
        RepositoryName = "GIT-URL"
        BranchName = "master"
        PollForSourceChanges = true
      }
    }
  }
  stage {
    name = "Build"
    action {
      name = "BuildAction"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["source"]
      output_artifacts = ["build"]
      configuration = {
        ProjectName = "web-app-pipeline"
      }
    }
  }
  stage {
    name = "Deploy"
    action {
      name = "DeployAction"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeDeploy"
      version = "1"
      input_artifacts = ["build"]
      configuration = {
        ApplicationName = aws_codedeploy_app.web_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.web_app_deployment.app_name
      }
    }
  }

  

}
