module LegalAidApplications
  class HasDependantsForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :has_dependants, :draft

    validates :has_dependants, presence: true, unless: :draft?
  end
end
