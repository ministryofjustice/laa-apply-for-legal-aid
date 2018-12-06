module LegalAidApplications
  class SharedOwnershipForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :shared_ownership

    validates :shared_ownership, presence: { message: 'blank' }
  end
end
