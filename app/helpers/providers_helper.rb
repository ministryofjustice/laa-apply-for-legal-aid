module ProvidersHelper
  def url_for_application(legal_aid_application)
    name = legal_aid_application.provider_step.presence || :proceedings_types

    flow_service = Flow::ProviderFlowService.new(
      legal_aid_application: legal_aid_application,
      current_step: name.to_sym
    )

    if legal_aid_application.means_completed?
      flow_service.start_path(:merits_start)
    else
      flow_service.current_path
    end
  end
end
