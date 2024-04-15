class LinkedApplication < ApplicationRecord
  belongs_to :lead_application, class_name: "LegalAidApplication", optional: true
  belongs_to :associated_application, class_name: "LegalAidApplication"

  validate :cannot_link_self

  validates :link_type_code, inclusion: LinkedApplicationType.all.map(&:code).append("false"), allow_nil: true

private

  def cannot_link_self
    errors.add(:lead_application_id, :cannot_link_self) if lead_application == associated_application
  end
end
