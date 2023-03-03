resource "pagerduty_event_orchestration" "default" {
  name        = "My Global Events Orchestration"
  description = "Global Orchestration Key to manage and direct all default alerts and notifications to the correct services within pagerduty"
  team        = pagerduty_team.default.id
}

// catch all unrouted events
resource "pagerduty_event_orchestration_unrouted" "unrouted" {
  event_orchestration = pagerduty_event_orchestration.default.id
  set {
    id = "start"
    rule {
      label = "Always trigger an alert in case of unrouted events"
      actions {
        event_action = "trigger"
        extraction {
          target   = "event.component"
          template = "pagerduty"
        }
      }
    }
  }
  catch_all {
    actions {
      severity = "info"
    }
  }
}

// route all events for services which have an orchestration_expression defined
resource "pagerduty_event_orchestration_router" "default" {
  event_orchestration = pagerduty_event_orchestration.default.id
  set {
    id = "start"
    dynamic "rule" {
      for_each = { for key, service in local.technical_services :
      key => service if service.orchestration_expression != null }

      content {
        label = "route events for service: ${rule.key}"
        condition {
          expression = rule.value.orchestration_expression
        }
        actions {
          route_to = pagerduty_service.default_technical_service[rule.key].id
        }
      }
    }
  }
  catch_all {
    actions {
      route_to = pagerduty_service.default_technical_service["dummy"].id
    }
  }
}

// create incidents with right priority for all services with an orchestration_expression defined
resource "pagerduty_event_orchestration_service" "default" {
  for_each = { for key, service in local.technical_services :
  key => service if service.orchestration_expression != null }

  service = pagerduty_service.default_technical_service[each.key].id

  // for modifying orchestration rules see also:
  // https://registry.terraform.io/providers/PagerDuty/pagerduty/latest/docs/resources/event_orchestration_service
  // https://developer.pagerduty.com/docs/ZG9jOjM1NTE0MDc0-pager-duty-condition-language-pcl
  set {
    id = "start"

    // custom rule 1
    rule {
      label = "Set priority for non-production alerts"
      condition {
        expression = "event.source matches '.*(development|staging)'"
      }
      actions {
        severity = "info"
      }
    }
    // custom rule 2
    rule {
      label = "Set priority for production alerts"
      condition {
        expression = "event.source matches '.*(production)'"
      }
      actions {
        severity = "error"
      }
    }

    // set critical to p1
    rule {
      label = "All critical alerts should be treated as P1 incident"
      condition {
        expression = "event.severity matches 'critical'"
      }
      actions {
        priority = data.pagerduty_priority.p1.id
      }
    }
    // set error to p2
    rule {
      label = "All error alerts should be treated as P2 incident"
      condition {
        expression = "event.severity matches 'error'"
      }
      actions {
        priority = data.pagerduty_priority.p2.id
      }
    }
    // set warn to p3
    rule {
      label = "All warn alerts should be treated as P3 incident"
      condition {
        expression = "event.severity matches 'warn'"
      }
      actions {
        priority = data.pagerduty_priority.p3.id
      }
    }
    // all alerts with severity lower than warn should be ignored (e.g. non-prod)
  }

  // All alerts without critical/error should be treated as P3 incident"
  catch_all {
    actions {
      priority = data.pagerduty_priority.p3.id
    }
  }
}
