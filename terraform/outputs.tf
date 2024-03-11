##########################################################################
# outputs.tf - (optional) Contains outputs from the resources created
# @see https://developer.hashicorp.com/terraform/language/values/outputs
##########################################################################

output "pingone_envid" {
  value = pingone_environment.my_environment.id
}

output "contractor_access_client_id" {
  value = pingone_application.contractor_access.oidc_options[0].client_id
  sensitive = true
}

output "contractor_access_client_secret" {
  value = pingone_application.contractor_access.oidc_options[0].client_secret
  sensitive = true
}

output "worker_app_client_id" {
  value = pingone_application.worker_app.oidc_options[0].client_id
  sensitive = true
}

output "worker_app_client_secret" {
  value = pingone_application.worker_app.oidc_options[0].client_secret
  sensitive = true
}

output "account_claim_dv_app_api_key" {
  #value     = resource.davinci_application.account_claim_dv_app.api_keys.prod
  value     = "coming soon"
  sensitive = true
}

output "account_claimed_policy" {
  #value =  davinci_application_flow_policy.account_claimed_policy.id
  value     = "coming soon"
}
