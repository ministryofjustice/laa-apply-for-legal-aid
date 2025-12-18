module Providers
  class ResumesController < ProviderBaseController
    skip_back_history_for :show
    skip_provider_step_update_for :show

    def show
      redirect_to url_for_application(legal_aid_application)
    end

  private

    def url_for_application(legal_aid_application)
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
  end
end
