module FlowHelpers
  # Takes the last request path and uses it to determine the next step from flows
  # Makes some assumptions so may not work with every request
  def flow_forward_path
    path = request.path
    parts = path.split('/').select(&:present?)
    journey = parts.first.to_sym
    step_index = journey == :citizens ? 1 : 3
    current_step = parts[step_index].pluralize.to_sym
    legal_aid_application = journey == :citizens ? LegalAidApplication.new : LegalAidApplication.find(parts[2])
    flow = Flow::BaseFlowService.flow_service_for(
      journey,
      legal_aid_application: legal_aid_application,
      current_step: current_step
    )
    flow.forward_path
  end
end
