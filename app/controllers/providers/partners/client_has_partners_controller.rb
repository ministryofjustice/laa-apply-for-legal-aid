module Providers
  module Partners
    class ClientHasPartnersController < ProviderBaseController
      def show
        @form = ::Partners::ClientHasPartnerForm.new(model: applicant)
      end

      def update
        @form = ::Partners::ClientHasPartnerForm.new(form_params)
        render :show unless save_continue_or_draft(@form, has_partner: @form.has_partner?)
      end

    private

      def applicant
        legal_aid_application.applicant
      end

      def form_params
        merge_with_model(applicant) do
          params.expect(applicant: [:has_partner])
        end
      end
    end
  end
end
