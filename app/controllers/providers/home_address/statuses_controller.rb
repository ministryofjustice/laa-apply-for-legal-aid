module Providers
  module HomeAddress
    class StatusesController < ProviderBaseController
      prefix_step_with :home_address
      reviewed_by :legal_aid_application, :check_provider_answers

      def show
        @form = ::HomeAddress::StatusForm.new(model: applicant)
        @correspondence_address = applicant.address
      end

      def update
        unreview!

        @form = ::HomeAddress::StatusForm.new(form_params)
        @correspondence_address = applicant.address

        render :show unless save_continue_or_draft(@form)
      end

    private

      def applicant
        legal_aid_application.applicant
      end

      def form_params
        merge_with_model(applicant) do
          params.expect(applicant: [:no_fixed_residence])
        end
      end
    end
  end
end
