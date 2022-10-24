module Providers
  module Means
    class HousingBenefitsController < ProviderBaseController
      before_action :redirect_unless_enhanced_bank_upload_enabled

      def show
        @form = HousingBenefitForm.new(legal_aid_application:)
      end

      def update
        @form = HousingBenefitForm.new(housing_benefit_params)

        if @form.save
          go_forward
        else
          render :show, status: :unprocessable_entity
        end
      end

    private

      def housing_benefit_params
        params
          .require(:providers_means_housing_benefit_form)
          .permit(:transaction_type_ids, :housing_benefit_amount, :housing_benefit_frequency)
          .merge(legal_aid_application:)
      end

      def redirect_unless_enhanced_bank_upload_enabled
        unless Setting.enhanced_bank_upload?
          go_forward
        end
      end
    end
  end
end
