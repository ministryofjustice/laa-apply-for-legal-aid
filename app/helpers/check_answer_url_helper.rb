module CheckAnswerUrlHelper
  def check_answer_url_for(journey_type, field_name, application = nil, args = {})
    flow_service = Flow::BaseFlowService.flow_service_for(
      journey_type,
      current_step: field_name,
      legal_aid_application: application,
      params: args,
    )
    [flow_service.current_path, field_name].compact.join("#")
  end
end
