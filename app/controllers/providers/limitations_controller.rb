module Providers
  class LimitationsController < ProviderBaseController
    def show
      @form = LegalAidApplications::EmergencyCostOverrideForm.new(model: legal_aid_application)
      legal_aid_application.enter_applicant_details! unless no_state_change_required?
    end

    def update
      if form_needs_checking?
        clear_limit_and_reason
        @form = LegalAidApplications::EmergencyCostOverrideForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      else
        continue_or_draft
      end
    end

  private

    def no_state_change_required?
      legal_aid_application.entering_applicant_details? || legal_aid_application.checking_applicant_details?
    end

    def form_needs_checking?
      @legal_aid_application.emergency_cost_overridable? || @legal_aid_application.substantive_cost_overridable?
    end

    def clear_limit_and_reason
      atc = params[:legal_aid_application]

      atc[:emergency_cost_requested] = nil if atc[:emergency_cost_override].to_s == "false"
      atc[:emergency_cost_reasons] = nil if atc[:emergency_cost_override].to_s == "false"
      atc[:substantive_cost_requested] = nil if atc[:substantive_cost_override].to_s == "false"
      atc[:substantive_cost_reasons] = nil if atc[:substantive_cost_override].to_s == "false"
    end

    def form_params
      merge_with_model(legal_aid_application) do
        params.expect(legal_aid_application: %i[emergency_cost_override
                                              emergency_cost_requested
                                              emergency_cost_reasons
                                              substantive_cost_override
                                              substantive_cost_requested
                                              substantive_cost_reasons])
      end
    end
  end
end
