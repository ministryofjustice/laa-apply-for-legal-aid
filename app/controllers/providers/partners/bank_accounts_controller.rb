module Providers
  module Partners
    class BankAccountsController < ProviderBaseController
      prefix_step_with :partner

      helper_method :attributes

      def show
        @form = ::Partners::OfflineAccountsForm.new(model: savings_amount)
      end

      def update
        @form = ::Partners::OfflineAccountsForm.new(form_params)

        render :show unless save_continue_or_draft(@form)
      end

    private

      def attributes
        @attributes ||= ::Partners::OfflineAccountsForm::ATTRIBUTES
      end

      def check_box_attributes
        ::Partners::OfflineAccountsForm::CHECK_BOXES_ATTRIBUTES
      end

      def savings_amount
        @savings_amount ||= legal_aid_application.savings_amount || legal_aid_application.build_savings_amount
      end

      def form_params
        merge_with_model(savings_amount, journey: journey_type) do
          params.expect(savings_amount: [attributes + check_box_attributes])
        end
      end
    end
  end
end
