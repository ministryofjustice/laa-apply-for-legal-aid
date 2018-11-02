class BenefitCheckResult < ApplicationRecord
  belongs_to :legal_aid_application

  POSITIVE_RESULT = 'yes'.freeze

  def positive?
    result.to_s.downcase == POSITIVE_RESULT
  end
end
