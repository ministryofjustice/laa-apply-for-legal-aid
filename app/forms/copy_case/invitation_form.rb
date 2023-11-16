module CopyCase
  class InvitationForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :copied_case

    validates :copied_case, presence: true, unless: proc { draft? || copied_case.present? }
  end
end
