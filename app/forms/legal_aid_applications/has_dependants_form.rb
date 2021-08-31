module LegalAidApplications
  class HasDependantsForm < NewBaseForm

    form_for LegalAidApplication

    attr_accessor :has_dependants

    validates :has_dependants, presence: true
  end
end
