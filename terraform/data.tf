##########################################################################
# data.tf - Declarations for PingOne data.
# {@link https://developer.hashicorp.com/terraform/language/data-sources}
##########################################################################

# PingOne Application Roles
# {@link https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/data-sources/role}
# {@link https://docs.pingidentity.com/r/en-us/pingone/p1_t_configurerolesforworkerapplication}
# Identity Data Admin Role

data "pingone_role" "identity_data_admin" {
  name = "Identity Data Admin"
}

# PingOne Application Roles
# {@link https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/data-sources/role}
# {@link https://docs.pingidentity.com/r/en-us/pingone/p1_t_configurerolesforworkerapplication}
# Identity Data Admin Role
data "pingone_population" "default_pop" {
  environment_id = pingone_environment.my_environment.id

  name = "Default"
}


##############################################
# DaVinci Connections
# {@link https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/data-sources/connection}
##############################################

data "davinci_connection" "pingone_by_name" {
  environment_id = pingone_environment.my_environment.id
  name           = "PingOne"

  depends_on = [
    data.davinci_connections.read_all,
  ]
}

data "davinci_connection" "http_by_name" {
  environment_id = pingone_environment.my_environment.id
  name           = "Http"

  depends_on = [
    data.davinci_connections.read_all,
  ]
}

data "davinci_connection" "annotation_by_name" {
  environment_id = pingone_environment.my_environment.id
  name           = "Annotation"

  depends_on = [
    data.davinci_connections.read_all,
  ]
}

data "davinci_connection" "pingone_mfa_by_name" {
  environment_id = pingone_environment.my_environment.id
  name           = "PingOne MFA"

  depends_on = [
    data.davinci_connections.read_all,
  ]
}

data "davinci_connection" "variable_by_name" {
  environment_id = pingone_environment.my_environment.id
  name           = "Variables"

  depends_on = [
    data.davinci_connections.read_all,
  ]
}

data "davinci_connection" "pingone_authentication_by_name" {
  environment_id = pingone_environment.my_environment.id
  name           = "PingOne Authentication"

  depends_on = [
    data.davinci_connections.read_all,
  ]
}

data "davinci_connection" "teleport_by_name" {
  environment_id = pingone_environment.my_environment.id
  name           = "Node"

  depends_on = [
    data.davinci_connections.read_all,
  ]
}
