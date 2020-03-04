module CCMS
  # Determines whether or not a manual review of the application by case workers is required
  # true means yes, false means no (the opposite of the APPLY_CASE_MEANS_REVIEW attribute in the payload)
  class ManualReviewDeterminer
    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
      raise 'Unable to determine whether Manual review is required before means assessment' if legal_aid_application.cfe_result.nil?
    end

    def call
      return true if Setting.manually_review_all_cases?

      return true if contribution_required?

      false
    end

    private

    def contribution_required?
      @legal_aid_application.cfe_result.contribution_required?
    end
  end
end
