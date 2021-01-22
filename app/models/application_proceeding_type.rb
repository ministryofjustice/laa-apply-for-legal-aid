class ApplicationProceedingType < ApplicationRecord
  FIRST_PROCEEDING_CASE_ID = 55_000_000

  belongs_to :legal_aid_application
  belongs_to :proceeding_type

  before_create do
    self.proceeding_case_id = highest_proceeding_case_id + 1 if proceeding_case_id.blank?
    self.lead_proceeding = true if proceedings.empty?
  end

  def proceeding_case_p_num
    "P_#{proceeding_case_id}"
  end

  private

  def highest_proceeding_case_id
    rec = self.class.order(proceeding_case_id: :desc).first
    rec.nil? || rec.proceeding_case_id.nil? ? FIRST_PROCEEDING_CASE_ID : rec.proceeding_case_id
  end

  def proceedings
    ApplicationProceedingType.where(legal_aid_application_id: legal_aid_application.id)
  end
end
