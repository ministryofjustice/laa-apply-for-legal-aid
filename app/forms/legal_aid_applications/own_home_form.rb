module LegalAidApplications
  class OwnHomeForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :own_home

    validates :own_home, presence_partner_optional: { partner_labels: :has_partner_with_no_contrary_interest? }, unless: :draft?

    delegate :own_home_no?, :own_home_mortgage?, :own_home_owned_outright?, to: :model
  end
end
