module HMRC
  class StatusAnalyzer
    delegate :provider,
             :applicant,
             :has_multiple_employments?,
             :hmrc_employment_income?,
             to: :legal_aid_application

    attr_reader :legal_aid_application

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      return :employed_journey_not_enabled unless Setting.enable_employed_journey?

      return :provider_not_enabled_for_employed_journey unless provider.employment_permissions?

      return :applicant_not_employed unless applicant.employed?

      return :hmrc_multiple_employments if has_multiple_employments?

      return :no_hmrc_data unless hmrc_employment_income?

      :hmrc_single_employment
    end
  end
end
