terraform {
  required_version = ">= 1.3.0"

  required_providers {
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = "2.6.2"
    }
  }

  /*
  backend "azurerm" {
    resource_group_name  = "rg-pagerduty"
    storage_account_name = "stpagerduty"
    container_name       = "terraform"
    key                  = "pagerduty.tfstate"

    subscription_id = ""
    tenant_id       = ""
  }
  */
}

locals {
  technical_services = merge(
    var.technical_services_team1,
    var.technical_services_team2,
  )

  business_services = merge(
    var.business_services_team1,
    var.business_services_team2,
  )
}

resource "pagerduty_team" "default" {
  name = var.pd_team_name
}

// existing users
data "pagerduty_user" "users" {
  for_each = var.users
  email    = each.key
}

// existing priorities

// major (red in service graph)
data "pagerduty_priority" "p1" {
  name = "P1"
}
// high prio / high urgency (orange in service graph)
data "pagerduty_priority" "p2" {
  name = "P2"
}
// mid prio / high urgency (grey in service graph)
data "pagerduty_priority" "p3" {
  name = "P3"
}
// low prio / low? urgency (grey in service graph)
data "pagerduty_priority" "p4" {
  name = "P4"
}
// low prio / low? urgency (grey in service graph)
data "pagerduty_priority" "p5" {
  name = "P5"
}

resource "pagerduty_team_membership" "default_group_membership" {
  for_each = data.pagerduty_user.users

  user_id = each.value.id
  team_id = pagerduty_team.default.id

  role = lookup(var.users, each.key).pagerduty_role
}
