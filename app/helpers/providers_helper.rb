module ProvidersHelper
  def link_to_application(text, legal_aid_application)
    govuk_link_to(text, url_for_application(legal_aid_application))
  end

  def url_for_application(legal_aid_application)
    return providers_legal_aid_application_task_list_path(legal_aid_application) if ENV.fetch("EDITABLE_APPLICATIONS", "false") == "true"

    name = if legal_aid_application.expired?
             :providers_blocked
           else
             legal_aid_application.provider_step.presence || :proceedings_types
           end

    Flow::ProviderFlowService.new(
      legal_aid_application:,
      current_step: name.to_sym,
      params: legal_aid_application.provider_step_params&.symbolize_keys,
    ).current_path
  rescue Flow::FlowError => e
    AlertManager.capture_exception(e)
    Rails.logger.error e.message

    journey_start_path(legal_aid_application)
  end

  def journey_start_path(legal_aid_application)
    Flow::KeyPoint.path_for(
      journey: :providers,
      key_point: :edit_applicant,
      legal_aid_application:,
    )
  end

  def tag_colour(legal_aid_application)
    case legal_aid_application.summary_state
    when :expired
      "red"
    when :submitted
      "green"
    else
      "blue"
    end
  end
end
