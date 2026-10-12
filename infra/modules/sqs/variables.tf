variable "environment" {
  description = "The environment of the application"
  type        = string
}

variable "tags" {
  description = "The tags of the application"
  type        = map(string)
}