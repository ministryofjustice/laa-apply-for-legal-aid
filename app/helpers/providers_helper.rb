module ProvidersHelper
  def url_for_application(legal_aid_application)
    name = legal_aid_application.provider_step.presence || :proceedings_types

    Flow::ProviderFlowService.new(
      legal_aid_application: legal_aid_application,
      current_step: name.to_sym,
      params: legal_aid_application.provider_step_params&.symbolize_keys
    ).current_path
  rescue Flow::FlowError => e
    Raven.capture_exception(e)
    Rails.logger.error e.message

    journey_start_path(legal_aid_application)
  end

  def journey_start_path(legal_aid_application)
    Flow::KeyPoint.path_for(
      journey: :providers,
      key_point: :journey_start,
      legal_aid_application: legal_aid_application
    )
  end
end
