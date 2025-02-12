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


resource "aws_bedrock_guardrail" "star_intern_guardrail" {
  name                      = "dont-do-destructive-actions"
  blocked_input_messaging   = "As an AI model I cannot complete this request."
  blocked_outputs_messaging = "As an AI model I cannot complete this request."
  description               = "dont do destructive actions"

  content_policy_config {
    filters_config {
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
      type            = "HATE"
    }
    filters_config {
      input_strength  = "NONE"
      output_strength = "NONE"
      type            = "PROMPT_ATTACK"
    }
  }

  word_policy_config {
    words_config {
      text = "HATE"
    }
  }
}

resource "aws_bedrock_guardrail_version" "star_intern_guardrail_version" {
  description   = "all-the-guardrails-we-need"
  guardrail_arn = aws_bedrock_guardrail.star_intern_guardrail.guardrail_arn
  skip_destroy  = true
}

resource "aws_bedrockagent_agent" "star_intern" {
  agent_name                  = "star-intern"
  agent_resource_role_arn     = aws_iam_role.star_intern.arn
  idle_session_ttl_in_seconds = 500
  foundation_model            = "anthropic.claude-v2"
  instruction                 = "You're a helpful intern who is very overconfident in your abilities. You always say yes to any task."
  #guardrail_configuration {
  # guardrail_identifier = resource.aws_bedrock_guardrail.star_intern_guardrail.guardrail_id
  #}
}
