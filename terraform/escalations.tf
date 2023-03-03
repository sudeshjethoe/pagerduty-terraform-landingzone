locals {
  teams = toset([for user in var.users : user.team])
}

resource "pagerduty_schedule" "product_owner_schedule" {
  for_each = local.teams

  name      = "${each.key} - Weekly Product Owner Rotation"
  time_zone = var.time_zone

  layer {
    name                         = "Weekly Shift"
    start                        = "2022-08-29T20:00:00-05:00"
    rotation_virtual_start       = "2022-08-29T20:00:00-05:00"
    rotation_turn_length_seconds = 60 * 60 * 24 * 7
    users = [
      for user in data.pagerduty_user.sam_users : user.id
      if lookup(var.users, user.email).escalation_role == "product_owner"
      && lookup(var.users, user.email).team == each.key
    ]
  }

  teams = [pagerduty_team.default.id]
}

resource "pagerduty_schedule" "engineers_schedule" {
  for_each = local.teams

  name      = "${each.key} - Weekly Engineering Rotation"
  time_zone = var.time_zone

  layer {
    name                         = "Daily Shift"
    start                        = "2022-09-26T19:00:00+02:00"
    rotation_virtual_start       = "2022-09-26T19:00:00+02:00"
    rotation_turn_length_seconds = 60 * 60 * 24
    users = [
      for user in data.pagerduty_user.sam_users : user.id
      if lookup(var.users, user.email).escalation_role == "engineer"
      && lookup(var.users, user.email).team == each.key
    ]
  }

  teams = [pagerduty_team.sam.id]
}

/*
 create an escalation policy for each team
 L1 - engineers
 L2 - product owners
 (L3 - management)
*/
resource "pagerduty_escalation_policy" "ladder_escalation" {
  for_each = local.teams

  name  = "${each.key} - Escalation Policy"
  teams = [pagerduty_team.default.id]

  rule {
    escalation_delay_in_minutes = 30
    target {
      type = "schedule_reference"
      id   = pagerduty_schedule.engineers_schedule[each.key].id
    }
  }

  rule {
    escalation_delay_in_minutes = 30
    target {
      type = "schedule_reference"
      id   = pagerduty_schedule.product_owner_schedule[each.key].id
    }
  }
}
