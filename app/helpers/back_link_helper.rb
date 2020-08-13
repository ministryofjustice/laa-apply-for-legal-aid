module BackLinkHelper
  def back_link_url_for(journey_type, field_name, application = nil, *args)
    flow_service = Flow::BaseFlowService.flow_service_for(
      journey_type,
      current_step: field_name,
      legal_aid_application: application,
      params: Hash[*args]
    )
    flow_service.back_path
  end
end
