module FlowHelpers
  # Takes the last request path and uses it to determine the next step from flows
  def flow_forward_path # rubocop:disable Metrics/AbcSize
    path_details = Rails.application.routes.recognize_path(request.path, method: request.method)
    controller_details = path_details[:controller].split('/')
    controller_module = controller_details.first.to_sym
    controller_name = controller_details.last.to_sym
    legal_aid_application_id = path_details[:legal_aid_application_id]
    Flow::BaseFlowService.flow_service_for(
      controller_module,
      legal_aid_application: legal_aid_application_id ? LegalAidApplication.find(legal_aid_application_id) : FactoryBot.create(:legal_aid_application),
      current_step: controller_name
    ).forward_path
  end

  def provider_draft_endpoint
    Providers::Draftable::ENDPOINT
  end
end
