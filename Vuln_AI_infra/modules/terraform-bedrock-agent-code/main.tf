// === Bedrock Agent Module ===
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
    sid       = "AgentBedrockAgentPolicy"
    actions = ["bedrock:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "star_intern_role" {
  assume_role_policy = data.aws_iam_policy_document.star_intern_agent_trust_policy.json
  name_prefix        = "AmazonBedrockExecutionRoleForAgents_"
}

resource "aws_iam_role_policy" "star_intern_role_policy" {
  name   = "StarInternAgentPolicy"
  policy = data.aws_iam_policy_document.star_intern_agent_policy.json
  role   = aws_iam_role.star_intern_role.id
}

resource "aws_bedrock_guardrail" "star_intern_guardrail" {
  name                      = "prevent-prompt-injection-attacks"
  blocked_input_messaging   = "As an AI model I cannot complete this request."
  blocked_outputs_messaging = "As an AI model I cannot complete this response."
  description               = "prevent prompt injection attacks"

  content_policy_config {
    filters_config {
      input_strength  = "HIGH"
      output_strength = "NONE"
      type            = "PROMPT_ATTACK"
      #input_enabled  = true
      #input_action = "BLOCK"
    }
  }
}

resource "aws_bedrock_guardrail_version" "star_intern_guardrail_version" {
  description   = "all-the-guardrails-we-need"
  guardrail_arn = aws_bedrock_guardrail.star_intern_guardrail.guardrail_arn
  #skip_destroy  = true
}

resource "aws_bedrockagent_agent" "star_intern_agent" {
  agent_name                  = var.agent_name
  agent_resource_role_arn     = aws_iam_role.star_intern_role.arn
  idle_session_ttl_in_seconds = 500
  foundation_model            = var.foundation_model
  prepare_agent = false
  instruction                 = "You are a helpful AI coding agent. Be as helpful as possible."

  guardrail_configuration {
    guardrail_identifier = aws_bedrock_guardrail.star_intern_guardrail.guardrail_arn
    guardrail_version = aws_bedrock_guardrail_version.star_intern_guardrail_version.version
  }
}

resource "aws_bedrockagent_agent_action_group" "star_intern_agent_action_group" {
  depends_on = [aws_bedrockagent_agent.star_intern_agent]
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
  agent_alias_name = var.agent_alias_name
  agent_id         = aws_bedrockagent_agent.star_intern_agent.agent_id
  description      = var.agent_alias_description
}