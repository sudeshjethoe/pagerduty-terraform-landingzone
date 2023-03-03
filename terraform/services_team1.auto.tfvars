# File: sam_services_hydra.auto.tfvars
# This file auto loads the services from hydra

technical_services_hydra = {
  ## nodes ##
  "ram-pega-search" = {
    component                = "pega"
    group                    = "ram-pega"
    orchestration_expression = "event.source matches regex 'ram-.*-pega-search-.*@kubernetes'"
    depends_on = [
      "ram-traefik"
    ]
    description = <<EOM
    the pega cluster for ram
    EOM
  },
  "ram-pega-stream" = {
    component                = "pega"
    group                    = "ram-pega"
    orchestration_expression = "event.source matches regex 'ram-.*-pega-stream-.*@kubernetes'"
    depends_on = [
      "ram-pega-search",
      "ram-postgresql",
      "ram-traefik",
      "oracle-api-gateway"
    ]
    description = <<EOM
    the pega cluster for ram
    EOM
  }
  "ram-pega-web" = {
    component                = "pega"
    group                    = "ram-pega"
    orchestration_expression = "event.source matches regex 'ram-.*-pega-web-.*@kubernetes'"
    depends_on = [
      "ram-pega-search",
      "ram-pega-stream",
      "ram-traefik",
      "ram-postgresql",
      "oracle-api-gateway"
    ]
    description = <<EOM
    the pega cluster for ram
    EOM
  }
  ## batches ##
  sam-cros-caoverdraft = {
    component                = "sam-event-batches"
    group                    = "sam-batches"
    orchestration_expression = "event.component matches part 'cros-cp'"
    description              = <<EOM
      CAOverdraft Batch
    EOM
    depends_on = [
      "sam-cros-sensor"
    ]
  }
}

business_services_hydra = {
  ram-pega = {
    depends_on = [
      "ram-pega-web",
      "ram-pega-search",
      "ram-pega-stream",
    ]
  }
}
