module Providers
  module HomeAddress
    class DifferentAddressReasonsController < ProviderBaseController
      def show
        @form = ::HomeAddress::DifferentAddressReasonForm.new(model: applicant)
      end

      def update
        @form = ::HomeAddress::DifferentAddressReasonForm.new(form_params)

        render :show unless save_continue_or_draft(@form)
      end

    private

      def applicant
        legal_aid_application.applicant
      end

      def form_params
        merge_with_model(applicant) do
          next {} unless params[:applicant]

          params.require(:applicant).permit(:no_fixed_residence)
        end
      end
    end
  end
end
