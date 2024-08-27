module Providers
  module CorrespondenceAddress
    class ChoicesController < ProviderBaseController
      prefix_step_with :correspondence_address

      def show
        @form = Addresses::ChoiceForm.new(model: applicant)
      end

      def update
        @form = Addresses::ChoiceForm.new(form_params)

        delete_client_no_fixed_residence if form_params[:correspondence_address_choice].eql?("home")

        render :show unless save_continue_or_draft(@form)
      end

    private

      def applicant
        legal_aid_application.applicant
      end

      def delete_client_no_fixed_residence
        applicant.no_fixed_residence = nil
        applicant.save!
      end

      def form_params
        merge_with_model(applicant) do
          next {} unless params[:applicant]

          params.require(:applicant).permit(:correspondence_address_choice)
        end
      end
    end
  end
end
