module Editing
  class DWPDataCleaner
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      legal_aid_application.update!(dwp_result_confirmed: nil)
      legal_aid_application.dwp_override&.destroy!
      legal_aid_application.benefit_check_result&.destroy!

      legal_aid_application.applicant&.update!(shared_benefit_with_partner: nil)
      legal_aid_application.partner&.update!(shared_benefit_with_applicant: nil)
    end

  private

    attr_reader :legal_aid_application
  end
end
