class ApplicationProceedingType < ApplicationRecord
  FIRST_PROCEEDING_CASE_ID = 55_000_001

  belongs_to :legal_aid_application
  belongs_to :proceeding_type

  def proceeding_case_p_num
    "P_#{proceeding_case_id}"
  end
end
