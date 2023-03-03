/*
 pagerduty_role: manager / observer / responder
 escalation_role: product_owner / engineer / analyst
 team: team1 / team2 / team3
 */
users = {
  "user1@acme.corp" = {
    pagerduty_role  = "manager"
    escalation_role = "engineer"
    team            = "team1"
  },
  "user2@acme.corp" = {
    pagerduty_role  = "responder"
    escalation_role = "product_owner"
    team            = "team1"
  },
  "user3@acme.corp" = {
    pagerduty_role  = "manager"
    escalation_role = "engineer"
    team            = "team1"
  }
}

