class LinkedApplication < ApplicationRecord
  belongs_to :lead_application, class_name: "LegalAidApplication"
  belongs_to :associated_application, class_name: "LegalAidApplication"

  validate :cannot_link_self

private

  def cannot_link_self
    errors.add(:linked_application_ref, I18n.t("activemodel.errors.models.linked_application.attributes.application_cannot_be_linked_to_itself.message")) if lead_application == associated_application
  end
end
