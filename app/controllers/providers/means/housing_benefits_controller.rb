module Providers
  module Means
    class HousingBenefitsController < ProviderBaseController
      def show
        @individual = individual
        @form = HousingBenefitForm.new(legal_aid_application:)
      end

      def update
        @individual = individual
        @form = HousingBenefitForm.new(housing_benefit_params)

        if @form.save
          go_forward
        else
          render :show, status: :unprocessable_content
        end
      end

    private

      def housing_benefit_params
        params
          .require(:providers_means_housing_benefit_form)
          .permit(:transaction_type_ids, :housing_benefit_amount, :housing_benefit_frequency)
          .merge(legal_aid_application:)
      end

      def individual
        show_for_partner = legal_aid_application.housing_payments_for?("Partner")
        show_for_client = legal_aid_application.housing_payments_for?("Applicant") && legal_aid_application.uploading_bank_statements?
        if show_for_partner && show_for_client
          I18n.t("generic.client_or_partner")
        else
          show_for_partner ? I18n.t("generic.partner") : I18n.t("generic.client")
        end
      end
    end
  end
end
