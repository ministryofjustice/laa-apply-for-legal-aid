module CopyCase
  class InvitationForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :copy_case

    validates :copy_case, presence: true, unless: proc { draft? || copy_case.present? }
  end
end
