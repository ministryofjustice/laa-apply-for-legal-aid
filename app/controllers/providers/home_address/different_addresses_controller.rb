module Providers
  module HomeAddress
    class DifferentAddressesController < ProviderBaseController
      def show
        @form = ::HomeAddress::DifferentAddressForm.new(model: applicant)
        @correspondence_address = applicant.address
      end

      def update
        @form = ::HomeAddress::DifferentAddressForm.new(form_params)
        @correspondence_address = applicant.address

        render :show unless save_continue_or_draft(@form)
      end

    private

      def applicant
        legal_aid_application.applicant
      end

      def form_params
        merge_with_model(applicant) do
          params.require(:applicant).permit(:different_home_address)
        end
      end
    end
  end
end
