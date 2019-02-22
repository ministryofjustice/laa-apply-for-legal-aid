module LegalAidApplications
  class OwnHomeForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :own_home

    validates :own_home, presence: { message: 'blank' }, unless: :draft?

    after_validation { model.clear_property_details if own_home_no? }

    delegate :own_home_no?, :own_home_mortgage?, :own_home_owned_outright?, to: :model
  end
end
