module Providers
  module Partners
    class RegularOutgoingsController < ProviderBaseController
      prefix_step_with :partner

      def show
        @form = RegularOutgoingsForm.new(legal_aid_application:)
      end

      def update
        @form = RegularOutgoingsForm.new(regular_outgoings_params)

        if @form.save
          go_forward
        else
          render :show, status: :unprocessable_entity
        end
      end

    private

      def regular_outgoings_params
        params
          .require(:providers_partners_regular_outgoings_form)
          .permit(regular_transaction_params, transaction_type_ids: [])
          .merge(legal_aid_application:)
      end

      def regular_transaction_params
        RegularOutgoingsForm::OUTGOING_TYPES.map { |outgoing_type|
          [:"#{outgoing_type}_amount", :"#{outgoing_type}_frequency"]
        }.flatten
      end
    end
  end
end
