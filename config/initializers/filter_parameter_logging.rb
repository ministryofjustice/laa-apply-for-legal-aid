# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += %i[
  password
  statement
  name
  date_of_birth
  national_insurance_number
  address
  city
  county
  post_code
  email
  emergency_cost_reasons
  understands_terms_of_court_order_details
  warning_letter_sent_details
  bail_conditions_set_details
  success_prospect_details_marginal
  secret
  token
  _key
  crypt
  salt
  certificate
  otp
  ssn
]
