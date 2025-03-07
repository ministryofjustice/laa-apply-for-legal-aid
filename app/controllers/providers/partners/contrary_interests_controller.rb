module Providers
  module Partners
    class ContraryInterestsController < ProviderBaseController
      def show
        @form = ::Partners::ContraryInterestsForm.new(model: applicant)
      end

      def update
        @form = ::Partners::ContraryInterestsForm.new(form_params)
        remove_partner if @form.partner_has_contrary_interest?
        render :show unless save_continue_or_draft(@form, partner_has_contrary_interest: @form.partner_has_contrary_interest?)
      end

    private

      def applicant
        legal_aid_application.applicant
      end

      def form_params
        merge_with_model(applicant) do
          params.expect(applicant: [:partner_has_contrary_interest])
        end
      end

      def remove_partner
        partner = legal_aid_application.partner
        partner&.destroy!
      end
    end
  end
end
