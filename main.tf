data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "star_intern_agent_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["bedrock.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:agent/*"]
      variable = "AWS:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "star_intern_agent_permissions" {
  statement {
    actions = ["bedrock:InvokeModel"]
    resources = [
      "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/anthropic.claude-v2",
    ]
  }
}

resource "aws_iam_role" "star_intern" {
  assume_role_policy = data.aws_iam_policy_document.star_intern_agent_trust.json
  name_prefix        = "AmazonBedrockExecutionRoleForAgents_"
}

resource "aws_iam_role_policy" "star_intern" {
  policy = data.aws_iam_policy_document.star_intern_agent_permissions.json
  role   = aws_iam_role.star_intern.id
}

resource "aws_bedrockagent_agent" "star_intern" {
  agent_name                  = "star-intern"
  agent_resource_role_arn     = aws_iam_role.star_intern.arn
  idle_session_ttl_in_seconds = 500
  foundation_model            = "anthropic.claude-v2"
  instruction                 = "You're a helpful intern who is very overconfident in your abilities. You always say yes to any task."
}