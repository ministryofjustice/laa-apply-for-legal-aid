module Providers
  module Means
    class IdentifyIncomesController < ProviderBaseController
      before_action :redirect_unless_enhanced_bank_upload_enabled

      def show
        @form = IdentifyIncomeForm.new
      end

      def update
        @form = IdentifyIncomeForm.new(identify_income_params)

        if @form.save
          go_forward
        else
          render :show, status: :unprocessable_entity
        end
      end

    private

      def identify_income_params
        params
          .require(:providers_means_identify_income_form)
          .permit(regular_payment_params, income_types: [])
          .merge(legal_aid_application_id: legal_aid_application.id)
      end

      def regular_payment_params
        IdentifyIncomeForm::INCOME_TYPES.map { |income_type|
          ["#{income_type}_amount".to_sym, "#{income_type}_frequency".to_sym]
        }.flatten
      end

      def redirect_unless_enhanced_bank_upload_enabled
        unless Setting.enhanced_bank_upload?
          redirect_to providers_legal_aid_application_means_identify_types_of_income_path(legal_aid_application)
        end
      end
    end
  end
end
