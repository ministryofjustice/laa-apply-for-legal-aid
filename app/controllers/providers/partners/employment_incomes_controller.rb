module Providers
  module Partners
    class EmploymentIncomesController < ProviderBaseController
      prefix_step_with :partner

      before_action :employments_and_payments

      def show
        @partner = partner
        @form = ::Partners::EmploymentIncomeForm.new(model: partner)
      end

      def update
        @partner = partner
        @form = ::Partners::EmploymentIncomeForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def partner
        @partner ||= legal_aid_application.partner
      end

      def employments_and_payments
        @employments = @legal_aid_application.partner.employments
        @eligible_employment_payments = @legal_aid_application.partner.eligible_employment_payments
      end

      def form_params
        merge_with_model(partner) do
          return {} unless params[:partner]

          params.expect(partner: %i[extra_employment_information extra_employment_information_details])
        end
      end
    end
  end
end
