##########################################################################
# davinci.tf - Declarations to create DaVinci assets
# {@link https://registry.terraform.io/providers/pingidentity/davinci/latest}
##########################################################################

#########################################################################
# PingOne DaVinci - Read all connections
#########################################################################
# {@link https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/data-sources/connections}


resource "time_sleep" "davinci" {
  create_duration = "120s"

  depends_on = [pingone_environment.my_environment]
}

data "davinci_connections" "read_all" {
  depends_on = [
    #pingone_role_assignment_user.davinci_admin_sso,
    time_sleep.davinci,
  ]
  environment_id = pingone_environment.my_environment.id
}


#########################################################################
# PingOne DaVinci - Create and deploy a flow
#########################################################################
# {@link https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow}

resource "davinci_flow" "account_claimed_flow" {
  depends_on = [
    data.davinci_connections.read_all
  ]

  flow_json = file("davinci/account-claimed-combined-flow.json")
  deploy    = true

  environment_id = pingone_environment.my_environment.id

  connection_link {
    id   = data.davinci_connection.http_by_name.id
    name = data.davinci_connection.http_by_name.name
  }

  connection_link {
    id   = data.davinci_connection.annotation_by_name.id
    name = data.davinci_connection.annotation_by_name.name
  }
}

#########################################################################
# PingOne DaVinci - Create an application and flow policy for the flow above
#########################################################################
# {@link https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/application}

resource "davinci_application" "account_claim_dv_app" {
  name           = "Account Claim"
  environment_id = pingone_environment.my_environment.id
  depends_on     = [data.davinci_connections.read_all]
  oauth {
    enabled = true
    values {
      allowed_grants                = ["authorizationCode"]
      allowed_scopes                = ["openid", "profile"]
      enabled                       = true
      enforce_signed_request_openid = false
      redirect_uris                 = ["${module.pingone_utils.pingone_url_auth_path_full}/rp/callback/openid_connect"]
    }
  }

  saml {
    values {
      enabled                = false
      enforce_signed_request = false
    }
  }
}

resource "davinci_application_flow_policy" "account_claimed_policy" {
  depends_on     = [data.davinci_connections.read_all]
  environment_id = pingone_environment.my_environment.id
  application_id = davinci_application.account_claim_dv_app.id
  name           = "Account Claim Combined"
  status         = "enabled"
  policy_flow {
    flow_id    = davinci_flow.account_claimed_flow.id
    version_id = -1
    weight     = 100
  }
}

resource "davinci_variable" "forgerock_host_url" {
  environment_id = pingone_environment.my_environment.id
  name           = "frHostUrl"
  context        = "company"
  description    = "AIC host url"
  value          = var.fr_host_url
  type           = "string"
  depends_on     = [data.davinci_connections.read_all]
}
