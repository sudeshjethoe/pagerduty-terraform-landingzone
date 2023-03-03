# File: sam_services_magma.auto.tfvars
# This file auto loads the services from team1

technical_services_team1 = {
  ## sam-cron-batches ##
  sam-cron-ntf = {
    component                = "sam-cron"
    group                    = "sam-batches"
    orchestration_expression = "event.source matches regex 'sam-cron-.*-ntf'"
    description              = <<EOM
      collection of services which are managed by the area
      "Special Asset Management" within Tribe Wonen
    EOM
    depends_on = [
    ]
  }
  sam-cron-inspire = {
    component                = "sam-cron"
    group                    = "sam-batches"
    orchestration_expression = "event.source matches regex 'sam-cron-.*-inspire'"
    description              = <<EOM
      collection of services which are managed by the area
      "Special Asset Management" within Tribe Wonen
    EOM
    depends_on = [
    ]
  },
  ## sam-cps-batches ##
  sam-cps-main = {
    component                = "sam-event-batches"
    group                    = "sam-batches"
    orchestration_expression = "event.component matches part 'cps-main'"
    description              = <<EOM
      CPS MAIN BATCH
    EOM
    depends_on = [
      "sam-cps-sensor"
    ]
  },
}

business_services_team1 = {}
