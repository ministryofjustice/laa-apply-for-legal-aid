module LegalAidApplications
  class HasDependantsForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :has_dependants, :draft

    validates :has_dependants, presence_partner_optional: { partner_labels: :has_partner_with_no_contrary_interest? }, unless: :draft?
  end
end
