##############################################
# PingOne Connections (applications)
##############################################

# PingOne Connection (application)
# {@link https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/application}
# {@link https://docs.pingidentity.com/r/en-us/pingone/p1_add_app_worker}
resource "pingone_application" "contractor_access" {
  environment_id = pingone_environment.my_environment.id
  enabled        = true
  name           = "Contractor Access"
  description    = "Contractor Access PingOne Web Application"

  oidc_options {
    type                        = "WEB_APP"
    grant_types                 = ["AUTHORIZATION_CODE"]
    response_types              = ["CODE"]
    token_endpoint_authn_method = "CLIENT_SECRET_BASIC"
  }

}

resource "pingone_application" "worker_app" {
  environment_id = pingone_environment.my_environment.id
  name           = "forgerock-wf-platform1"
  enabled        = true

  oidc_options {
    type                        = "WORKER"
    grant_types                 = ["CLIENT_CREDENTIALS"]
    token_endpoint_authn_method = "CLIENT_SECRET_BASIC"
  }
}


resource "pingone_key" "default_signing_key" {
  environment_id = pingone_environment.my_environment.id

  name                = "PingOne SSO Certificate for IDM Works Integration Environment"
  algorithm           = "RSA"
  key_length          = 4096
  signature_algorithm = "SHA256withRSA"
  subject_dn          = "C=US,O=Ping Identity,OU=Ping Identity,CN=PingOne SSO Certificate for IDM Works Integration environment"
  usage_type          = "SIGNING"
  validity_period     = 365
}

resource "pingone_application" "benefits_website" {
  environment_id = pingone_environment.my_environment.id
  name           = "Benefits Website"
  enabled        = true

  saml_options {
    acs_urls           = ["https://wf-platform1.encore.forgerock.com/apps/web/benefits/saml"]
    assertion_duration = 3600
    sp_entity_id       = "BenefitsWebsite"

    idp_signing_key {
      key_id    = pingone_key.default_signing_key.id
      algorithm = pingone_key.default_signing_key.signature_algorithm
    }

  }
}

resource "pingone_application" "company_website" {
  environment_id = pingone_environment.my_environment.id
  name           = "Company Website"
  enabled        = true

  saml_options {
    acs_urls           = ["https://wf-platform1.encore.forgerock.com/apps/web/company/saml"]
    assertion_duration = 3600
    sp_entity_id       = "corpapps"

    idp_signing_key {
      key_id    = pingone_key.default_signing_key.id
      algorithm = pingone_key.default_signing_key.signature_algorithm
    }

  }
}

resource "pingone_application" "engineering_website" {
  environment_id = pingone_environment.my_environment.id
  name           = "Engineering Website"
  enabled        = true

  saml_options {
    acs_urls           = ["https://wf-platform1.encore.forgerock.com/apps/web/benefits/saml"]
    assertion_duration = 3600
    sp_entity_id       = "EngineeringWebsite"

    idp_signing_key {
      key_id    = pingone_key.default_signing_key.id
      algorithm = pingone_key.default_signing_key.signature_algorithm
    }
  }
}

resource "pingone_application" "wf_platform_portal" {
  environment_id = pingone_environment.my_environment.id
  name           = "wf-platorm Portal"
  enabled        = true

  saml_options {
    acs_urls           = ["https://openam-wf-platform1.forgeblocks.com/am/Consumer/metaAlias/alpha/accessreview"]
    assertion_duration = 3600
    sp_entity_id       = "AccessReview"

    idp_signing_key {
      key_id    = pingone_key.default_signing_key.id
      algorithm = pingone_key.default_signing_key.signature_algorithm
    }

    #sp_verification {
      #certificate_ids      = [var.sp_verification_certificate_id]
      #authn_request_signed = true
    #}
  }
}



resource "pingone_application_attribute_mapping" "family_name" {
  environment_id = pingone_environment.my_environment.id
  application_id = pingone_application.benefits_website.id

  name  = "User.LastName"
  value = "$${user.name.family}"
}


resource "pingone_application" "access_request_link" {
  environment_id = pingone_environment.my_environment.id
  name           = "Access Request"
  enabled        = true

  external_link_options {
    home_page_url = "https://auth.pingone.com/ecbe2e03-7426-4df8-99af-faef0d8edcd8/saml20/idp/startsso?spEntityId=AccessReview&applicationUrl=https%3A%2F%2Fopenam-wf-platform1.forgeblocks.com%2Fenduser%2F%3Frealm%3Dalpha%23%2Fmy-requests"
  }
}

resource "pingone_application" "access_review_link" {
  environment_id = pingone_environment.my_environment.id
  name           = "Access Review"
  enabled        = true

  external_link_options {
    home_page_url = "https://auth.pingone.com/ecbe2e03-7426-4df8-99af-faef0d8edcd8/saml20/idp/startsso?spEntityId=AccessReview&applicationUrl=https%3A%2F%2Fopenam-wf-platform1.forgeblocks.com%2Fenduser%2F%3Frealm%3Dalpha%23%2Faccess-reviews"
  }
}

resource "pingone_application" "end_user_portal_link" {
  environment_id = pingone_environment.my_environment.id
  name           = "End User Portal"
  enabled        = true

  external_link_options {
    home_page_url = "https://auth.pingone.com/ecbe2e03-7426-4df8-99af-faef0d8edcd8/saml20/idp/startsso?spEntityId=AccessReview&applicationUrl=https%3A%2F%2Fopenam-wf-platform1.forgeblocks.com%2Fenduser%2F%3Frealm%3Dalpha%23%2Fapplications"
  }
}
##########################################################################
# resource.tf - Declarations for PingOne resources.
# {@link https://developer.hashicorp.com/terraform/language/resources}
# {@link https://docs.pingidentity.com/r/en-us/pingone/p1_c_resources}
##########################################################################

resource "pingone_role_assignment_user" "admin_sso_identity_admin" {
  environment_id       = var.pingone_environment_id
  user_id              = var.admin_user_id
  role_id              = data.pingone_role.identity_data_admin.id
  scope_environment_id = pingone_environment.my_environment.id
}


##########################################################################
# PingOne Role Assignment
# {@link https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/application_role_assignment}
# {@link https://docs.pingidentity.com/r/en-us/pingone/p1_t_configurerolesforworkerapplication}
##########################################################################


resource "pingone_application_role_assignment" "population_identity_data_admin_to_application" {
  environment_id = pingone_environment.my_environment.id
  application_id = pingone_application.worker_app.id
  role_id        = data.pingone_role.identity_data_admin.id

  scope_environment_id = pingone_environment.my_environment.id
}

resource "pingone_application_role_assignment" "population_environment_admin_to_application" {
  environment_id = pingone_environment.my_environment.id
  application_id = pingone_application.worker_app.id
  role_id        = data.pingone_role.environment_admin.id

  scope_environment_id = pingone_environment.my_environment.id
}


##########################################################################
# resource.tf - Declarations for PingOne resources.
# {@link https://developer.hashicorp.com/terraform/language/resources}
# {@link https://docs.pingidentity.com/r/en-us/pingone/p1_c_resources}
# {@link https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/gateway}
##########################################################################

#### WIP - RUNNING INTO PROVIDER ISSUES/BUGS ####
# resource "pingone_gateway" "my_radius_gateway" {
#   environment_id = var.pingone_environment_id
#   name           = "wf-platform1-radius-gw"
#   enabled        = true
#   type           = "RADIUS"

#   radius_default_shared_secret = var.gateway_secret
#   radius_davinci_policy_id     = "1a50eb7f-042d-453d-9cd4-57ff548e112c"

#   radius_client {
#     ip = "127.0.0.1"
#   }
# }


# resource "pingone_gateway" "my_ldap_gateway" {
#   bind_dn                                   = "CN=rproxy,CN=Users,DC=ad-wf-platform1,DC=encore,DC=forgerock,DC=org"
#   bind_password                             = var.gateway_secret
#   connection_security                       = "TLS"
#   description                               = null
#   enabled                                   = true
#   environment_id                            = var.pingone_environment_id
#   kerberos_retain_previous_credentials_mins = 0
#   kerberos_service_account_password         = var.gateway_secret
#   kerberos_service_account_upn              = "p1-kerb-svc@ad-wf-platform1.encore.forgerock.org"
#   name                                      = "wf-platform1-kerb-gw"
#   servers                                   = ["wf-platform1.ad-wf-platform1.encore.forgerock.org:636"]
#   type                                      = "LDAP"
#   validate_tls_certificates                 = true
#   vendor                                    = "Microsoft Active Directory"
#   user_type {
#     name                          = "Employee"
#     password_authority            = "PING_ONE"
#     push_password_changes_to_ldap = false
#     search_base_dn                = "OU=Encore,DC=ad-wf-platform1,DC=encore,DC=forgerock,DC=org"
#     user_link_attributes          = ["objectGUID", "objectSid", "sAMAccountName", "dn"]
#     user_migration {
#       lookup_filter_pattern = "(|(sAMAccountName=$${identifier})(mail=$${identifier}))"
#       population_id         = data.pingone_population.default_pop.id
#       attribute_mapping {
#         name  = "address.countryCode"
#         value = "$${ldapAttributes.c}"
#       }
#       attribute_mapping {
#         name  = "address.locality"
#         value = "$${ldapAttributes.l}"
#       }
#       attribute_mapping {
#         name  = "address.postalCode"
#         value = "$${ldapAttributes.postalCode}"
#       }
#       attribute_mapping {
#         name  = "address.region"
#         value = "$${ldapAttributes.st}"
#       }
#       attribute_mapping {
#         name  = "address.streetAddress"
#         value = "$${ldapAttributes.streetAddress}"
#       }
#       attribute_mapping {
#         name  = "email"
#         value = "$${ldapAttributes.mail}"
#       }
#       attribute_mapping {
#         name  = "externalId"
#         value = "$${ldapAttributes.mS-DS-ConsistencyGuid}"
#       }
#       attribute_mapping {
#         name  = "mobilePhone"
#         value = "$${ldapAttributes.mobile}"
#       }
#       attribute_mapping {
#         name  = "name.family"
#         value = "$${ldapAttributes.sn}"
#       }
#       attribute_mapping {
#         name  = "name.formatted"
#         value = "$${ldapAttributes.displayName}"
#       }
#       attribute_mapping {
#         name  = "name.given"
#         value = "$${ldapAttributes.givenName}"
#       }
#       attribute_mapping {
#         name  = "primaryPhone"
#         value = "$${ldapAttributes.telephoneNumber}"
#       }
#       attribute_mapping {
#         name  = "title"
#         value = "$${ldapAttributes.title}"
#       }
#       attribute_mapping {
#         name  = "username"
#         value = "$${ldapAttributes.sAMAccountName}"
#       }
#     }
#   }
# }
