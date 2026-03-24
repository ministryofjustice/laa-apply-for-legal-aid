module TaskStatus
  module Validators
    class Partner < Base
    private

      delegate :partner, :applicant, to: :application

      def forms
        if applicant&.has_partner?
          if applicant.partner_has_contrary_interest?
            [partner_details_form]
          else
            [partner_contrary_interest_form]
          end
        else
          [applicant_has_partner_form]
        end
      end

      def applicant_has_partner_form
        @applicant_has_partner_form ||= ::Partners::ClientHasPartnerForm.new(model: applicant)
      end

      def partner_contrary_interest_form
        @partner_contrary_interest_form ||= ::Partners::ContraryInterestsForm.new(model: applicant)
      end

      def partner_details_form
        @partner_details_form ||= ::Partners::DetailsForm.new(model: partner)
      end
    end
  end
end
