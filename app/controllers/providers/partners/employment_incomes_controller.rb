module Providers
  module Partners
    class EmploymentIncomesController < ProviderBaseController
      before_action :employments_and_payments

      def show
        @partner = partner
        @form = LegalAidApplications::EmploymentIncomeForm.new(model: legal_aid_application)
      end

      def update
        @partner = partner
        @form = LegalAidApplications::EmploymentIncomeForm.new(form_params)
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
        merge_with_model(legal_aid_application) do
          return {} unless params[:legal_aid_application]

          params.require(:legal_aid_application).permit(:extra_employment_information, :extra_employment_information_details)
        end
      end
    end
  end
end
