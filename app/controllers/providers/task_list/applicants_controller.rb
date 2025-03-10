# This is different from the Providers::ApplicantsController in on
# one major aspect. It does not create a legal_aid_application. This
# is because the legal_aid_application should have been created by
# the TaskListsController, from which this controller/page is reached.
#
module Providers
  module TaskList
    class ApplicantsController < ProviderBaseController
      def show
        @form = Applicants::BasicDetailsForm.new(model: applicant)
      end

      def create
        @form = Applicants::BasicDetailsForm.new(form_params)

        if save_continue_or_draft(@form)
          legal_aid_application.update!(
            applicant:,
            provider_step: edit_applicant_key_point.step,
          )
          replace_last_page_in_history(edit_applicant_path)
        else
          render :show
        end
      end

    private

      def legal_aid_application
        @legal_aid_application ||= LegalAidApplication.find_by(id: params[:legal_aid_application_id])
      end

      def applicant
        @applicant ||= legal_aid_application.applicant || Applicant.new
      end

      def edit_applicant_path
        edit_applicant_key_point.path(legal_aid_application)
      end

      def edit_applicant_key_point
        @edit_applicant_key_point ||= Flow::KeyPoint.new(:providers, :edit_applicant)
      end

      def form_params
        merged_params = merge_with_model(applicant) do
          params.expect(applicant: %i[first_name last_name date_of_birth changed_last_name last_name_at_birth])
        end
        convert_date_params(merged_params)
      end
    end
  end
end
