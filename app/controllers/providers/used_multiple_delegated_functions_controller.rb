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

      update_scope_limitations
      DelegatedFunctionsDateService.call(legal_aid_application, draft_selected: draft_selected?)

      draft_selected? ? continue_or_draft : go_forward(delegated_functions_used_over_month_ago?)
    end

    def form
      @form ||= LegalAidApplications::UsedMultipleDelegatedFunctionsForm.call(application_proceedings_by_name)
    end

    def proceeding_types
      @proceeding_types ||= legal_aid_application.proceeding_types
    end

    def application_proceedings_by_name
      @application_proceedings_by_name ||= legal_aid_application.application_proceedings_by_name
    end

    def application_proceeding_types
      application_proceedings_by_name.map(&:application_proceeding_type)
    end

    def delegated_functions_used_over_month_ago?
      return false if earliest_delegated_functions_date.nil?

      earliest_delegated_functions_date < 1.month.ago
    end

    def earliest_delegated_functions_date
      @earliest_delegated_functions_date ||= legal_aid_application.earliest_delegated_functions_date
    end

    # def earliest_delegated_functions_reported_date
    #   @earliest_delegated_functions_reported_date ||= legal_aid_application.earliest_delegated_functions_reported_date
    # end

    def update_scope_limitations
      earliest_delegated_functions_date ? add_delegated_scope_limitations : remove_delegated_scope_limitations
    end

    def add_delegated_scope_limitations
      proceeding_types.each do |proceeding_type|
        LegalFramework::AddAssignedScopeLimitationService.call(legal_aid_application, proceeding_type.id, :delegated)
      end
    end

    def remove_delegated_scope_limitations
      application_proceeding_types.each(&:remove_default_delegated_functions_scope_limitation)
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
