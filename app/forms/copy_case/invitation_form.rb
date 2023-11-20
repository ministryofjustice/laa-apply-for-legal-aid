module CopyCase
  class InvitationForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :copy_case

    validates :copy_case, presence: true, unless: :draft?

    after_validation { model.copy_case_id = nil }
  end
end
