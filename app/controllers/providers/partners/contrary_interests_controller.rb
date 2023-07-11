module Providers
  module Partners
    class ContraryInterestsController < ProviderBaseController
      def show
        @form = ::Partners::ContraryInterestsForm.new(model: applicant)
      end

      def update
        @form = ::Partners::ContraryInterestsForm.new(form_params)
        render :show unless save_continue_or_draft(@form, partner_has_contrary_interest: @form.partner_has_contrary_interest?)
      end

    private

      def applicant
        legal_aid_application.applicant
      end

      def form_params
        merge_with_model(applicant) do
          params.require(:applicant).permit(:partner_has_contrary_interest)
        end
      end
    end
  end
end
