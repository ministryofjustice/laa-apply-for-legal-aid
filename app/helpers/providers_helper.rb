module ProvidersHelper
  def link_to_application(text, legal_aid_application)
    link_to_accessible text, url_for_application(legal_aid_application)
  end

  def url_for_application(legal_aid_application)
    name = legal_aid_application.provider_step.presence || :proceedings_types

    Flow::ProviderFlowService.new(
      legal_aid_application: legal_aid_application,
      current_step: name.to_sym,
      params: legal_aid_application.provider_step_params&.symbolize_keys
    ).current_path
  rescue Flow::FlowError => e
    Sentry.capture_exception(e)
    Rails.logger.error e.message

    journey_start_path(legal_aid_application)
  end

  def journey_start_path(legal_aid_application)
    Flow::KeyPoint.path_for(
      journey: :providers,
      key_point: :edit_applicant,
      legal_aid_application: legal_aid_application
    )
  end
end
