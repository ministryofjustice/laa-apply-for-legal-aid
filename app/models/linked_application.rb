class LinkedApplication < ApplicationRecord
  belongs_to :lead_application, class_name: "LegalAidApplication"
  belongs_to :associated_application, class_name: "LegalAidApplication"

  validate :cannot_link_self

private

  def cannot_link_self
    errors.add(:lead_application_id, :cannot_link_self) if lead_application == associated_application
  end
end