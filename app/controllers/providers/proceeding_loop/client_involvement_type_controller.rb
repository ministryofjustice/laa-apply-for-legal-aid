module Providers
  module ProceedingLoop
    class ClientInvolvementTypeController < ProviderBaseController
      before_action :proceeding

      def show
        @form = Proceedings::ClientInvolvementTypeForm.new(model: proceeding, cit_types:)
      end

      def update
        @form = Proceedings::ClientInvolvementTypeForm.new(form_params.merge({ cit_types: }))
        render :show unless save_continue_or_draft(@form)
      end

    private

      def proceeding
        @proceeding = Proceeding.find(proceeding_id_param)
      end

      def cit_types
        @cit_types ||= LegalFramework::ClientInvolvementTypes::Proceeding.call(proceeding.ccms_code, applicant_age)
      end

      def applicant_date_of_birth
        @applicant_date_of_birth ||= legal_aid_application.applicant&.date_of_birth
      end

      def applicant_age
        return nil unless applicant_date_of_birth

        as_of = proceeding.used_delegated_functions_on || Date.current
        AgeCalculator.call(applicant_date_of_birth, as_of)
      end

      def proceeding_id_param
        params.require(:id)
      end

      def form_params
        merge_with_model(proceeding) do
          return {} unless params[:proceeding]

          params.expect(proceeding: [:client_involvement_type_ccms_code])
        end
      end
    end
  end
end
