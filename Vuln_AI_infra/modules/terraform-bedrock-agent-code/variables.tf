variable "agent_name" {
  description = "Name of the agent"
  type = string
  default = "star-intern"
}

variable "foundation_model" {
  description = "The LLM Model to use"
  type        = string
  default     = "amazon.nova-pro-v1:0"
}

variable "agent_alias_name" {
  description = "Name of the agent alias"
  type        = string
  default     = "star_intern_agent_alias"
}

variable "agent_alias_description" {
  description = "Description of the agent alias"
  type        = string
  default     = "Just an alias for the star intern agent"
}

