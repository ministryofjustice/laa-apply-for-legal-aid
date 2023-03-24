module Providers
  module Partner
    class ClientHasPartnersController < ProviderBaseController
      include PreDWPCheckVisible

      def show
        @form = Providers::Partners::ClientHasPartnerForm.new(model: applicant)
      end

      def update
        @form = Providers::Partners::ClientHasPartnerForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def applicant
        legal_aid_application.applicant
      end

      def form_params
        merge_with_model(applicant) do
          params.require(:applicant).permit(:has_partner)
        end
      end
    end
  end
end
