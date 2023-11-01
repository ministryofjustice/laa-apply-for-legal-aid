module LinkingCase
  class InvitationForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :link_case

    validates :link_case, presence: true, unless: proc { draft? || link_case.present? }
  end
end
