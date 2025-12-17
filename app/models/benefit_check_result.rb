class BenefitCheckResult < ApplicationRecord
  belongs_to :legal_aid_application

  POSITIVE_RESULT = "yes".freeze

  def positive?
    result.to_s.downcase == POSITIVE_RESULT
  end

  def failure?
    result.to_s.downcase.start_with?("failure:")
  end
end
