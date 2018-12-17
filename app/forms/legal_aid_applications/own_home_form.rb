module LegalAidApplications
  class OwnHomeForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :own_home

    validates :own_home, presence: { message: 'blank' }

    delegate :own_home_no?, :own_home_mortgage?, :own_home_owned_outright?, to: :model
  end
end
