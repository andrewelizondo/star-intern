output "agent_id" {
    description = "The ID of the agent"
    value       = aws_bedrockagent_agent.star_intern_agent.agent_id
}

output "agent_arn" {
    description = "The ARN of the agent"
    value       = aws_bedrockagent_agent.star_intern_agent.agent_arn
}

output "agent_alias_id" {
    description = "The alias ID of the agent"
    value       = aws_bedrockagent_agent_alias.star_intern_agent_alias.agent_alias_id
}

output "agent_action_group_id" {
    description = "The ID of the agent action group"
    value       = aws_bedrockagent_agent_action_group.star_intern_agent_action_group.action_group_id
}

output "agent_action_group_name" {
    description = "The name of the agent action group"
    value       = aws_bedrockagent_agent_action_group.star_intern_agent_action_group.action_group_name
}