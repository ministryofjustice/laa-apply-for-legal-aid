module Providers
  module CorrespondenceAddress
    class ChoicesController < ProviderBaseController
      prefix_step_with :correspondence_address

      def show
        @form = Addresses::ChoiceForm.new(model: applicant)
        legal_aid_application.enter_applicant_details! unless no_state_change_required?
      end

      def update
        untrack!(:check_provider_answers)

        @form = Addresses::ChoiceForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def no_state_change_required?
        legal_aid_application.entering_applicant_details? || legal_aid_application.checking_applicant_details?
      end

      def applicant
        legal_aid_application.applicant
      end

      def form_params
        merge_with_model(applicant) do
          next {} unless params[:applicant]

          params.expect(applicant: [:correspondence_address_choice])
        end
      end
    end
  end
end
