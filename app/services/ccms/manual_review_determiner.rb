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

    delegate :dwp_override,
             :passported?,
             :non_passported?,
             :has_restrictions?,
             :policy_disregards?,
             :capital_disregards?,
             :manually_entered_employment_information?,
             :manual_client_employment_information?,
             :manual_partner_employment_information?,
             :uploading_bank_statements?,
             :client_uploading_bank_statements?,
             :negative_equity?,
             :partner_uploading_bank_statements?, to: :legal_aid_application

    delegate :capital_contribution_required?, to: :cfe_result

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
      if legal_aid_application.cfe_result.nil?
        raise "Unable to determine whether Manual review is required before means assessment"
      end
    end

    def manual_review_required?
      dwp_overridden? ||
        manually_review_all_non_passported? ||
        capital_contribution_required? ||
        has_restrictions? ||
        policy_disregards? ||
        capital_disregards? ||
        manually_entered_employment_information? ||
        uploading_bank_statements? ||
        negative_equity?
    end

    def review_reasons
      (cfe_review_reasons + application_review_reasons).uniq
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
      application_review_reasons = []
      application_review_reasons << :dwp_override if dwp_overridden?
      application_review_reasons << :restrictions if has_restrictions?
      application_review_reasons << :policy_disregards if policy_disregards?
      application_review_reasons << :capital_disregards if capital_disregards?
      application_review_reasons << :non_passported if non_passported?
      application_review_reasons << :client_further_employment_details if manual_client_employment_information?
      application_review_reasons << :partner_further_employment_details if manual_partner_employment_information?
      application_review_reasons << :client_uploaded_bank_statements if client_uploading_bank_statements?
      application_review_reasons << :partner_uploaded_bank_statements if partner_uploading_bank_statements?
      application_review_reasons << :ineligible if cfe_result.ineligible?
      application_review_reasons << :negative_equity if negative_equity?
      application_review_reasons
    end

    def dwp_overridden?
      dwp_override.present? && dwp_override.values_at(:passporting_benefit, :has_evidence_of_benefit).all?(&:present?)
    end

    def manually_review_all_non_passported?
      Setting.manually_review_all_cases? && non_passported?
    end
  end
end
