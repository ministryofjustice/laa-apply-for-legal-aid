module CheckAnswerUrlHelper
  def check_answer_url_for(journey_type, field_name, application = nil, args = {})
    flow_service = Flow::BaseFlowService.flow_service_for(
      journey_type,
      current_step: field_name,
      legal_aid_application: application,
      params: args
    )
    anchor = field_name_to_anchor_map[field_name]
    [flow_service.current_path, anchor].compact.join('#')
  end

  # Used to append '#<anchor>' to urls for field names that need an anchor
  def field_name_to_anchor_map
    {
      property_values: :property_value,
      outstanding_mortgages: :outstanding_mortgage_amount,
      percentage_homes: :percentage_home
    }
  end
end
