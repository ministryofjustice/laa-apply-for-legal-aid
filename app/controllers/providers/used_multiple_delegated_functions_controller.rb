module Providers
  class UsedMultipleDelegatedFunctionsController < ProviderBaseController
    include PreDWPCheckVisible

    def show
      form
    end

    def update
      render :show unless save_continue_and_update_scope_limitations
    end

    private

    def save_continue_and_update_scope_limitations
      form.draft = draft_selected?
      return unless form.save(form_params)

      DelegatedFunctionsDateService.call(legal_aid_application, draft_selected: draft_selected?)

      draft_selected? ? continue_or_draft : go_forward(delegated_functions_used_over_month_ago?)
    end

    def form
      @form ||= LegalAidApplications::UsedMultipleDelegatedFunctionsForm.call(proceedings_by_name)
    end

    def proceedings_by_name
      @proceedings_by_name ||= legal_aid_application.proceedings_by_name
    end

    def delegated_functions_used_over_month_ago?
      return false if earliest_delegated_functions_date.nil?

      earliest_delegated_functions_date < 1.month.ago
    end

    def earliest_delegated_functions_date
      @earliest_delegated_functions_date ||= legal_aid_application.earliest_delegated_functions_date
    end

    def form_params
      merged_params = params.require(:legal_aid_applications_used_multiple_delegated_functions_form)
                            .except(:delegated_functions)
      convert_date_params(merged_params)
    end

    def draft_selected?
      params.key?(:draft_button)
    end
  end
end
