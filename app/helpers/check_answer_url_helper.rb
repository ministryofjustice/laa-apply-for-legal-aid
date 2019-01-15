module CheckAnswerUrlHelper
  URL_HELPERS = Rails.application.routes.url_helpers

  URLS = {
    citizen: {
      own_home: -> { URL_HELPERS.citizens_own_home_path },
      property_value: -> { URL_HELPERS.citizens_property_value_path(anchor: :property_value) },
      outstanding_mortgage: -> { URL_HELPERS.citizens_outstanding_mortgage_path(anchor: :outstanding_mortgage_amount) },
      shared_ownership: -> { URL_HELPERS.citizens_shared_ownership_path },
      percentage_home: -> { URL_HELPERS.citizens_percentage_home_path(anchor: 'percentage_home') },
      savings_and_investments: -> { URL_HELPERS.citizens_savings_and_investment_path },
      other_assets: -> { URL_HELPERS.citizens_other_assets_path },
      restrictions: -> { URL_HELPERS.citizens_restrictions_path }
    },
    provider: {
      own_home: ->(application) { URL_HELPERS.providers_legal_aid_application_own_home_path(application) },
      property_value: ->(application) { URL_HELPERS.providers_legal_aid_application_property_value_path(application, anchor: :property_value) },
      outstanding_mortgage: ->(application) { URL_HELPERS.providers_legal_aid_application_outstanding_mortgage_path(application, anchor: :outstanding_mortgage_amount) },
      shared_ownership: ->(application) { URL_HELPERS.providers_legal_aid_application_shared_ownership_path(application) },
      percentage_home: ->(application) { URL_HELPERS.providers_legal_aid_application_percentage_home_path(application, anchor: 'percentage_home') },
      savings_and_investments: ->(application) { URL_HELPERS.providers_legal_aid_application_savings_and_investment_path(application) },
      other_assets: ->(application) { URL_HELPERS.providers_legal_aid_application_other_assets_path(application) },
      restrictions: ->(application) { URL_HELPERS.providers_legal_aid_application_restrictions_path(application) }
    }
  }.freeze

  def check_answer_url_for(user_type, field_name, application = nil)
    raise ArgumentError, 'Wrong user type passed to #check_answer_url_for' if URLS[user_type].nil?
    raise ArgumentError, "Invalid field name for #check_answer_url_for: #{field_name}" if URLS[user_type][field_name].nil?

    proc = URLS[user_type][field_name]
    application.nil? ? proc.yield : proc.yield(application)
  end
end
