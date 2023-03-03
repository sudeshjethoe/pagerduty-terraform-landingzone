// see also: https://registry.terraform.io/providers/PagerDuty/pagerduty/latest/docs/resources/service

// create (technical) services
resource "pagerduty_service" "technical_service" {
  for_each = local.technical_services

  name        = each.key
  description = each.value.description

  // automatically close incidents after # days
  auto_resolve_timeout = 2 * 24 * 3600

  escalation_policy = pagerduty_escalation_policy.ladder_escalation[each.value.owner].id

  alert_creation = "create_alerts_and_incidents"

  incident_urgency_rule {
    type = "use_support_hours"

    during_support_hours {
      type    = "constant"
      urgency = "high"
    }

    outside_support_hours {
      type    = "constant"
      urgency = "low"
    }
  }

  support_hours {
    type         = "fixed_time_per_day"
    time_zone    = var.time_zone
    days_of_week = [1, 2, 3, 4, 5]
    start_time   = "07:00:00"
    end_time     = "19:00:00"
  }

  scheduled_actions {
    type       = "urgency_change"
    to_urgency = "high"

    at {
      type = "named_time"
      name = "support_hours_start"
    }
  }
}

// create business services
resource "pagerduty_business_service" "business_service" {
  for_each = local.business_services

  name        = each.key
  description = each.value.description

  point_of_contact = each.value.point_of_contact

  team = pagerduty_team.default.id
}
