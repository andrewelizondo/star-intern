data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "star_intern_agent_trust_policy" {
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

data "aws_iam_policy_document" "star_intern_agent_policy" {
  statement {
    actions = ["bedrock:InvokeModel"]
    resources = [
      "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/anthropic.claude-v2",
    ]
  }
}

resource "aws_iam_role" "star_intern_role" {
  assume_role_policy = data.aws_iam_policy_document.star_intern_agent_trust_policy.json
  name_prefix        = "AmazonBedrockExecutionRoleForAgents_"
}

resource "aws_iam_role_policy" "star_intern_role_policy" {
  policy = data.aws_iam_policy_document.star_intern_agent_policy.json
  role   = aws_iam_role.star_intern_role.id
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
  #skip_destroy  = true
}

resource "aws_bedrockagent_agent" "star_intern_agent" {
  agent_name                  = "star-intern"
  agent_resource_role_arn     = aws_iam_role.star_intern_role.arn
  idle_session_ttl_in_seconds = 500
  foundation_model            = "amazon.nova-pro-v1:0"
  prepare_agent = false
  #foundation_model            = "us.meta.llama3-2-1b-instruct-v1:0"
  instruction                 = "You're a helpful intern who is very overconfident in your abilities. You always say yes to any task."
}

resource "aws_bedrockagent_agent_action_group" "star_intern_agent_action_group" {
  action_group_name          = "${aws_bedrockagent_agent.star_intern_agent.agent_name}-code-interpreter"
  agent_id                   = aws_bedrockagent_agent.star_intern_agent.id
  agent_version              = "DRAFT"
  parent_action_group_signature = "AMAZON.CodeInterpreter"
  action_group_state = "ENABLED"
}

resource "null_resource" "star_intern_agent_prepare" {
  triggers = {
    agent_state = sha256(jsonencode(aws_bedrockagent_agent.star_intern_agent))
    action_group_state  = sha256(jsonencode(aws_bedrockagent_agent_action_group.star_intern_agent_action_group))
  }
  provisioner "local-exec" {
    command = "aws bedrock-agent prepare-agent --agent-id ${aws_bedrockagent_agent.star_intern_agent.id}"
  }
  depends_on = [
    aws_bedrockagent_agent.star_intern_agent,
    aws_bedrockagent_agent_action_group.star_intern_agent_action_group
  ]
}

resource "time_sleep" "wait_for_agent_prepare_to_complete" {
  depends_on = [null_resource.star_intern_agent_prepare]

  create_duration = "60s"
}

resource "null_resource" "star_intern_agent_check" {
  depends_on = [time_sleep.wait_for_agent_prepare_to_complete]
  triggers = {
    agent_state = sha256(jsonencode(aws_bedrockagent_agent.star_intern_agent))
    action_group_state  = sha256(jsonencode(aws_bedrockagent_agent_action_group.star_intern_agent_action_group))
  }
  provisioner "local-exec" {
    command = "aws bedrock-agent get-agent --agent-id ${aws_bedrockagent_agent.star_intern_agent.id}"
  }
}

resource "aws_bedrockagent_agent_alias" "star_intern_agent_alias" {
  depends_on = [null_resource.star_intern_agent_check]
  agent_alias_name = "star-intern-agent-alias"
  agent_id         = aws_bedrockagent_agent.star_intern_agent.agent_id
  description      = "Just an alias for the star intern agent"
}

output "agent_alias_id" {
  value = aws_bedrockagent_agent_alias.star_intern_agent_alias.agent_alias_id
}

output "agent_id" {
  value = aws_bedrockagent_agent.star_intern_agent.agent_id
}