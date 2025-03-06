module Providers
  module Partners
    class FullEmploymentDetailsController < ProviderBaseController
      prefix_step_with :partner

      def show
        @partner = partner
        @form = ::Partners::FullEmploymentDetailsForm.new(model: partner)
      end

      def update
        @form = ::Partners::FullEmploymentDetailsForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def partner
        legal_aid_application.partner || legal_aid_application.build_partner
      end

      def form_params
        merge_with_model(partner) do
          next {} unless params[:partner]

          params.expect(partner: [:full_employment_details])
        end
      end
    end
  end
end
