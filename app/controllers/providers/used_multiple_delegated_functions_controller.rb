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

      update_application

      draft_selected? ? continue_or_draft : go_forward(earliest_df&.used_delegated_functions_reported_on)
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

    def earliest_df
      form.earliest_delegated_functions
    end

    def earliest_df_date
      earliest_df&.used_delegated_functions_on
    end

    def update_application
      update_substantive_application_deadline
      earliest_df_date ? add_delegated_scope_limitations : remove_delegated_scope_limitations
      submit_application_reminder if !draft_selected? && earliest_df_date && earliest_df_date >= Date.current.ago(1.month)
    end

    def update_substantive_application_deadline
      legal_aid_application.substantive_application_deadline_on = substantive_application_deadline
      legal_aid_application.save!
    end

    def substantive_application_deadline
      return unless earliest_df_date

      SubstantiveApplicationDeadlineCalculator.call earliest_df
    end

    def add_delegated_scope_limitations
      proceeding_types.each do |proceeding_type|
        LegalFramework::AddAssignedScopeLimitationService.call(legal_aid_application, proceeding_type.id, :delegated)
      end
    end

    def remove_delegated_scope_limitations
      application_proceeding_types.each(&:remove_default_delegated_functions_scope_limitation)
    end

    def submit_application_reminder
      return if legal_aid_application.awaiting_applicant?
      return if legal_aid_application.applicant_entering_means?

      SubmitApplicationReminderService.new(legal_aid_application).send_email
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
