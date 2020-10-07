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
             :passported?,
             :non_passported?,
             :has_restrictions?, to: :legal_aid_application

    delegate :capital_contribution_required?, to: :cfe_result

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
      raise 'Unable to determine whether Manual review is required before means assessment' if legal_aid_application.cfe_result.nil?
    end

    def call
      return true if Setting.manually_review_all_cases? && non_passported?

      return true if capital_contribution_required? && has_restrictions?

      false
    end
  end
end
