/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "google" {
  version = "~> 3.85"
}

provider "google-beta" {
  version = "~> 3.85"
}

locals {
  team1_configs = [
    for cfg in fileset(path.module, "/configs/slos/team1/slo_*.yaml") :
    yamldecode(file(cfg))
  ]
  team2_configs = [
    for cfg in fileset(path.module, "/configs/slos/team2/slo_*.yaml") :
    yamldecode(file(cfg))
  ]
}

# Team1 deploys their SLOs configs to a bucket located in their own project, but 
# do not want to manage the slo-generator service.
module "team1-slos" {
  source         = "../../../modules/slo-generator"
  project_id     = var.team1_project_id
  region         = var.region
  slo_configs    = local.team1_configs
  service_url    = module.slo-generator.service_url
  create_service = false
}

# Team23 manages their own slo-generator service, but still want to export to 
# the shared destinations to get SRE insights.
module "team2-slos" {
  source       = "../../../modules/slo-generator"
  project_id   = var.team2_project_id
  region       = var.region
  config       = local.config
  slo_configs  = local.team1_configs
  service_name = "slo-generator-team2"
}