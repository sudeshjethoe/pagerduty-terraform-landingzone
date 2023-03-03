variable "time_zone" {
  type    = string
  default = "Europe/Amsterdam"
}

variable "pd_team_name" {
  type    = string
  default = "Pagerduty - Terraform Default Team"
}

variable "users" {
  type = map(object({
    pagerduty_role  = string
    escalation_role = string
    team            = string
  }))
}

# region ## technical services ##
variable "technical_services_team1" {
  type = map(object({
    orchestration_expression = optional(string)
    component                = string
    group                    = string
    owner                    = optional(string, "team1")
    depends_on               = list(string)
    description              = string
  }))
}
variable "technical_services_team2" {
  type = map(object({
    orchestration_expression = optional(string)
    component                = string
    group                    = string
    owner                    = optional(string, "team2")
    depends_on               = list(string)
    description              = string
  }))
}
# endregion ## technical services ##

# region ## business services ##
variable "business_services_team1" {
  type = map(object({
    description      = optional(string, "These service are managed by team1")
    point_of_contact = optional(string, "team1@acme.corp")
    depends_on       = list(string)
  }))
}
variable "business_services_team2" {
  type = map(object({
    description      = optional(string, "These service are managed by team2")
    point_of_contact = optional(string, "team2@acme.corp")
    depends_on       = list(string)
  }))
}
# endregion ## business services ##
