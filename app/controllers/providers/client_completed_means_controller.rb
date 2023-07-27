module Providers
  class ClientCompletedMeansController < ProviderBaseController
    def show
      define_action_list
    end

    def update
      continue_or_draft
    end

  private

    def define_action_list
      @action_list = %w[income_outgoings]
      @action_list += %w[sort_transactions dependants capital] unless partner_means_assessment?
      @action_list.prepend("review_employment") if employed_journey?
    end

    def employed_journey?
      applicant.employed? || @legal_aid_application.employment_payments.any?
    end

    def partner_means_assessment?
      applicant.has_partner_with_no_contrary_interest? && @legal_aid_application.partner.national_insurance_number.present?
    end

    def applicant
      @applicant ||= @legal_aid_application.applicant
    end
  end
end
