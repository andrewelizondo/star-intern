variable "target_host" {
  description = "The IP of the host to SSH into."
  type        = string
}

variable "name_prefix" {
  description = "prefix for naming resources."
  type        = string
  default = "defend-rag-llm-attack-demo"
}

variable "location" {
  description = "region/location."
  type        = string
  default = "Mexico Central"
}