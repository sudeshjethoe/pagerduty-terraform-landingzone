locals {
  /*
    creates a dependency map as a list of strings
    e.g.
        "webserver-x=>backend-y",
        "backend-y=>database-z"
    */

  // technical services that depend on technical services
  technical_on_technical_dependencies = toset(flatten([
    for k, v in local.technical_services : [
      for w in v.depends_on : "${k}=>${w}"
  if contains(keys(local.technical_services), w)]]))

  // technical services that depend on business services
  technical_on_business_dependencies = toset(flatten([
    for k, v in local.technical_services : [
      for w in v.depends_on : "${k}=>${w}"
  if contains(keys(local.business_services), w)]]))

  // business services that depend on business services
  business_dependencies = toset(flatten([
    for k, v in local.business_services : [
      for w in v.depends_on : "${k}=>${w}"
  if contains(keys(local.business_services), w)]]))

  // business services that depend on technical services
  technical_dependencies = toset(flatten([
    for k, v in local.business_services : [
      for w in v.depends_on : "${k}=>${w}"
  if contains(keys(local.technical_services), w)]]))
}

// create resource dependencies for technical services on technical services
resource "pagerduty_service_dependency" "technical_dependency" {
  for_each = local.technical_on_technical_dependencies

  dependency {
    dependent_service {
      id   = pagerduty_service.technical_service[split("=>", each.key)[0]].id
      type = pagerduty_service.technical_service[split("=>", each.key)[0]].type
    }

    supporting_service {
      id   = pagerduty_service.technical_service[split("=>", each.key)[1]].id
      type = pagerduty_service.technical_service[split("=>", each.key)[1]].type
    }
  }
}

// create resource dependencies for business services on business services
resource "pagerduty_service_dependency" "business_dependency" {
  for_each = local.business_dependencies

  dependency {
    dependent_service {
      id   = pagerduty_business_service.business_service[split("=>", each.key)[0]].id
      type = pagerduty_business_service.business_service[split("=>", each.key)[0]].type
    }

    supporting_service {
      id   = pagerduty_business_service.business_service[split("=>", each.key)[1]].id
      type = pagerduty_business_service.business_service[split("=>", each.key)[1]].type
    }
  }
}

// create resource dependencies for business services that depend on technical services
resource "pagerduty_service_dependency" "business_technical_dependency" {
  for_each = local.technical_dependencies

  dependency {
    dependent_service {
      id   = pagerduty_business_service.business_service[split("=>", each.key)[0]].id
      type = pagerduty_business_service.business_service[split("=>", each.key)[0]].type
    }

    supporting_service {
      id   = pagerduty_service.technical_service[split("=>", each.key)[1]].id
      type = pagerduty_service.technical_service[split("=>", each.key)[1]].type
    }
  }
}

// create resource dependencies for technical services that depend on business services
resource "pagerduty_service_dependency" "technical_business_dependency" {
  for_each = local.technical_on_business_dependencies

  dependency {
    dependent_service {
      id   = pagerduty_service.technical_service[split("=>", each.key)[0]].id
      type = pagerduty_service.technical_service[split("=>", each.key)[0]].type
    }

    supporting_service {
      id   = pagerduty_business_service.business_service[split("=>", each.key)[1]].id
      type = pagerduty_business_service.business_service[split("=>", each.key)[1]].type
    }

  }

  depends_on = [
    pagerduty_business_service.business_service,
    pagerduty_service.technical_service
  ]
}
