module CheckAnswerUrlHelper
  def check_answer_url_for(user_type, field_name, application = nil)
    case user_type
    when :provider
      check_answer_provider_url_for(field_name, application)
    when :citizen
      check_answer_citizen_url_for(field_name)
    else
      raise ArgumentError, 'Wrong user type passed to #check_answer_url_for'
    end
  end

  def check_answer_provider_url_for(field_name, application) # rubocop:disable Metrics/MethodLength
    case field_name
    when :own_home
      providers_legal_aid_application_own_home_path(application)
    when :property_value
      providers_legal_aid_application_property_value_path(application, anchor: :property_value)
    when :outstanding_mortgage
      providers_legal_aid_application_outstanding_mortgage_path(application, anchor: :outstanding_mortgage_amount)
    when :shared_ownership
      providers_legal_aid_application_shared_ownership_path
    when :percentage_home
      providers_legal_aid_application_percentage_home_path(anchor: 'percentage_home')
    when :savings_and_investments
      providers_legal_aid_application_savings_and_investment_path
    when :other_assets
      providers_legal_aid_application_other_assets_path
    when :restrictions
      providers_legal_aid_application_restrictions_path
    else
      raise ArgumentError, "Invalid field name for #check_answer_url_for: #{field_name}"
    end
  end

  def check_answer_citizen_url_for(field_name) # rubocop:disable Metrics/MethodLength
    case field_name
    when :own_home
      citizens_own_home_path
    when :property_value
      citizens_property_value_path(anchor: :property_value)
    when :outstanding_mortgage
      citizens_outstanding_mortgage_path(anchor: :outstanding_mortgage_amount)
    when :shared_ownership
      citizens_shared_ownership_path
    when :percentage_home
      citizens_percentage_home_path(anchor: 'percentage_home')
    when :savings_and_investments
      citizens_savings_and_investment_path
    when :other_assets
      citizens_other_assets_path
    when :restrictions
      citizens_restrictions_path
    else
      raise ArgumentError, "Invalid field name for #check_answer_url_for: #{field_name}"
    end
  end
end
