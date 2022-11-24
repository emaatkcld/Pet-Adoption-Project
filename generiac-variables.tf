# Input Variables
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "eu-west-2"
}
# Project Team
variable "project-team" {
  description = "Team Assigned the project (can be  used as a prefix)"
  type        = string
  default     = "EU2"
}
# Business Division (Pet Adoption Dvisison)
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type        = string
  default     = "PET"
}
