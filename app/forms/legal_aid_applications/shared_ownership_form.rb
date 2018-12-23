module LegalAidApplications
  class SharedOwnershipForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :shared_ownership

    validates :shared_ownership, presence: { message: 'blank' }

    delegate :shared_ownership?, to: :model
  end
end
