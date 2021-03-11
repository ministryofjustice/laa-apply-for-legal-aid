module CCMS
  # Determines whether or not a manual review of the application by case workers is required
  # true means yes, false means no (the opposite of the APPLY_CASE_MEANS_REVIEW attribute in the payload)
  #
  # This is used in two cases:
  #  - to determine the value of the APPLY_CASE_MEANS_REVIEW attribute for CCMS payload
  #  - to determine which header on the assessment results pages to display
  #
  class ManualReviewDeterminer
    attr_reader :legal_aid_application

    delegate :cfe_result,
             :dwp_override,
             :passported?,
             :non_passported?,
             :has_restrictions?, to: :legal_aid_application

    delegate :capital_contribution_required?, to: :cfe_result

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
      raise 'Unable to determine whether Manual review is required before means assessment' if legal_aid_application.cfe_result.nil?
    end

    def manual_review_required?
      dwp_override.present? ||
        manually_review_all_non_passported? ||
        capital_contribution_required? ||
        has_restrictions?
    end

    def review_reasons
      cfe_review_reasons + application_review_reasons
    end

    def review_categories_by_reason
      cfe_result.remarks.review_categories_by_reason
    end

    private

    def cfe_result
      @cfe_result ||= @legal_aid_application.cfe_result
    end

    def cfe_review_reasons
      cfe_result.remarks.review_reasons
    end

    def application_review_reasons
      dwp_override ? [:dwp_override] : []
    end

    def manually_review_all_non_passported?
      Setting.manually_review_all_cases? && non_passported?
    end
  end
end
