module Providers
  class UsedDelegatedFunctionsController < ProviderBaseController
    include PreDWPCheckVisible

    def show
      form
      form.used_delegated_functions = 'false' unless earliest_delegated_functions_date || referred_from_proceedings_search_page?
    end

    def update
      render :show unless save_continue_and_update_scope_limitations
    end

    private

    def save_continue_and_update_scope_limitations
      form.draft = draft_selected?
      return unless form.save(form_params)

      update_scope_limitations
      DelegatedFunctionsDateService.call(legal_aid_application) unless draft_selected?

      draft_selected? ? continue_or_draft : go_forward(earliest_delegated_functions_reported_date)
    end

    def form
      @form ||= LegalAidApplications::UsedDelegatedFunctionsForm.call(application_proceedings_by_name)
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

    def proceeding_with_earliest_delegated_functions
      @proceeding_with_earliest_delegated_functions ||= legal_aid_application.proceeding_with_earliest_delegated_functions
    end

    def earliest_delegated_functions_date
      @earliest_delegated_functions_date ||= proceeding_with_earliest_delegated_functions&.used_delegated_functions_on
    end

    def earliest_delegated_functions_reported_date
      @earliest_delegated_functions_reported_date ||= proceeding_with_earliest_delegated_functions&.used_delegated_functions_reported_on
    end

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
      merged_params = params.require(:legal_aid_applications_used_delegated_functions_form)
      convert_date_params(merged_params)
    end

    def draft_selected?
      params.key?(:draft_button)
    end

    def referred_from_proceedings_search_page?
      URI(request.referer || '').path.end_with? '/proceedings_types'
    end
  end
end
