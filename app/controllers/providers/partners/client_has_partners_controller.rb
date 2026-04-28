module Providers
  module Partners
    class ClientHasPartnersController < ProviderBaseController
      def show
        @form = ::Partners::ClientHasPartnerForm.new(model: applicant)
      end

      def update
        @form = ::Partners::ClientHasPartnerForm.new(form_params)
        remove_partner unless @form.has_partner?
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

      def remove_partner
        partner = legal_aid_application.partner
        partner&.destroy!
        applicant.update!(partner_has_contrary_interest: nil)
      end
    end
  end
end
