module Providers
  module Partners
    class UnexpectedEmploymentIncomesController < ProviderBaseController
      before_action :employments_and_payments

      def show
        partner
        @form = ::Partners::UnexpectedEmploymentIncomeForm.new(model: legal_aid_application)
      end

      def update
        partner
        @form = ::Partners::UnexpectedEmploymentIncomeForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def partner
        @partner ||= legal_aid_application.partner
      end

      def employments_and_payments
        @employments = partner.employments
        @eligible_employment_payments = partner.eligible_employment_payments
      end

      def form_params
        merge_with_model(partner) do
          return {} unless params[:partner]

          params.expect(partner: [:extra_employment_information_details])
        end
      end
    end
  end
end
