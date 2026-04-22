module TaskStatus
  module Validators
    class Partner < Base
      def valid?
        return false if missing_details?
        return true unless applicant&.has_partner?

        applicant.partner_has_contrary_interest? || partner_details_form.valid?
      end

    private

      delegate :partner, :applicant, to: :application

      def partner_details_form
        @partner_details_form ||= ::Partners::DetailsForm.new(model: partner)
      end

      def missing_details?
        applicant.nil? ||
          applicant.has_partner.nil? ||
          (applicant.has_partner? && applicant.partner_has_contrary_interest.nil?)
      end
    end
  end
end
