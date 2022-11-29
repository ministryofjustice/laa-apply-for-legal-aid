module Providers
  module BenefitCheckSkippable
  private

    def mark_as_benefit_check_skipped!(reason)
      legal_aid_application.create_benefit_check_result!(result: "skipped:#{reason}")
    end
  end
end
