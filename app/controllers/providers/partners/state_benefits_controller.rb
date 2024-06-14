module Providers
  module Partners
    class StateBenefitsController < ProviderBaseController
      prefix_step_with :partner

      def show
        @form = Providers::Means::StateBenefitForm.new(model: state_benefit_transaction)
      end

      def new
        @form = Providers::Means::StateBenefitForm.new(model: state_benefit_transaction)
      end

      def update
        @form = Providers::Means::StateBenefitForm.new(state_benefit_params)
        if @form.save
          go_forward
        else
          render @form.model.id.nil? ? :new : :show, status: :unprocessable_content
        end
      end

    private

      def state_benefit_transaction
        if params[:id].present? && params[:id] != "new"
          RegularTransaction.find(params[:id])
        else
          RegularTransaction.new(legal_aid_application:, transaction_type_id:, owner_id: owner.id, owner_type: "Partner")
        end
      end

      def transaction_type_id
        TransactionType.find_by!(name: "benefits").id
      end

      def owner
        legal_aid_application.partner
      end

      def state_benefit_params
        merge_with_model(state_benefit_transaction) do
          params.require(:regular_transaction).permit(:transaction_type_id, :description, :amount, :frequency)
        end
      end
    end
  end
end
