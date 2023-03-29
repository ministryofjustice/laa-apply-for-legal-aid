module Providers
  module Partners
    class DetailsController < ProviderBaseController
      def show
        @form = ::Partners::DetailsForm.new(model: partner)
      end

      def update
        @form = ::Partners::DetailsForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def partner
        @partner ||= legal_aid_application.partner || legal_aid_application.build_partner
      end

      def form_params
        merged_params = merge_with_model(partner) do
          params.require(:partner).permit(:first_name, :last_name, :date_of_birth, :has_national_insurance_number, :national_insurance_number)
        end
        convert_date_params(merged_params)
      end
    end
  end
end
