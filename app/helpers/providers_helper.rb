module ProvidersHelper
  def url_for_application(legal_aid_application)
    name = legal_aid_application.provider_step.presence || :proceedings_types

    Flow::ProviderFlowService.new(
      legal_aid_application: legal_aid_application,
      current_step: name.to_sym,
      params: legal_aid_application.provider_step_params&.symbolize_keys
    ).current_path
  end
end
