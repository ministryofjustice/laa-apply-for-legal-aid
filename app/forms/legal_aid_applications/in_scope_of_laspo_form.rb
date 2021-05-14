module LegalAidApplications
  class InScopeOfLaspoForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :in_scope_of_laspo

    validates :in_scope_of_laspo, presence: true
  end
end
