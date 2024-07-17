module LegalAidApplications
  class ConfirmSeparateRepresentationForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :separate_representation_required

    validates :separate_representation_required, presence: true, unless: :draft?
  end
end
