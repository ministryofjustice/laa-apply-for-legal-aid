module Providers
  module Means
    class RegularIncomesController < ProviderBaseController
      before_action :redirect_unless_enhanced_bank_upload_enabled

      def show
        @form = RegularIncomeForm.new(legal_aid_application:)
      end

      def update
        @form = RegularIncomeForm.new(regular_income_params)

        if @form.save
          go_forward
        else
          render :show, status: :unprocessable_entity
        end
      end

    private

      def regular_income_params
        params
          .require(:providers_means_regular_income_form)
          .permit(regular_transaction_params, transaction_type_ids: [])
          .merge(legal_aid_application:)
      end

      def regular_transaction_params
        RegularIncomeForm::INCOME_TYPES.map { |income_type|
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
