module Providers
  module Partners
    class RegularIncomesController < ProviderBaseController
      prefix_step_with :partner
      def show
        @form = RegularIncomeForm.new(legal_aid_application:)
      end

      def update
        @form = RegularIncomeForm.new(regular_income_params)

        if @form.save
          go_forward
        else
          render :show, status: :unprocessable_content
        end
      end

    private

      def regular_income_params
        params
          .require(:providers_partners_regular_income_form)
          .permit(regular_transaction_params, transaction_type_ids: [])
          .merge(legal_aid_application:)
      end

      def regular_transaction_params
        RegularIncomeForm::INCOME_TYPES.map { |income_type|
          [:"#{income_type}_amount", :"#{income_type}_frequency"]
        }.flatten
      end
    end
  end
end
