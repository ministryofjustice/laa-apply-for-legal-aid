module TaskStatus
  module Validators
    class DWPOverride < Base
    private

      def forms
        [
          received_benefit_confirmation_form,
          has_evidence_of_benefit_form,
        ]
      end

      def received_benefit_confirmation_form
        @received_benefit_confirmation_form ||= ::Providers::ReceivedBenefitConfirmationForm.new(model: dwp_override)
      end

      def has_evidence_of_benefit_form
        @has_evidence_of_benefit_form ||= ::LegalAidApplications::HasEvidenceOfBenefitForm.new(model: dwp_override)
      end
    end
  end
end
