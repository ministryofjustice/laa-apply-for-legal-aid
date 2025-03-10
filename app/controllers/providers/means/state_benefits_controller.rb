module Providers
  module Means
    class StateBenefitsController < ProviderBaseController
      def show
        @form = StateBenefitForm.new(model: state_benefit_transaction)
      end

      def new
        @form = StateBenefitForm.new(model: state_benefit_transaction)
      end

      def update
        @form = StateBenefitForm.new(state_benefit_params)
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
          RegularTransaction.new(legal_aid_application:, transaction_type_id:, owner_id: owner.id, owner_type: "Applicant")
        end
      end

      def transaction_type_id
        TransactionType.find_by!(name: "benefits").id
      end

      def owner
        legal_aid_application.applicant
      end

      def state_benefit_params
        merge_with_model(state_benefit_transaction) do
          params.expect(regular_transaction: %i[transaction_type_id description amount frequency])
        end
      end
    end
  end
end
