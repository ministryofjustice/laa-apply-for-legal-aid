module LegalAidApplications
  class HasDependantsForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :has_dependants

    validates :has_dependants, presence: true
  end
end
