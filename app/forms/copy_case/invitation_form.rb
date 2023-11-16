module CopyCase
  class InvitationForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :copied_case

    validates :copied_case, presence: true, unless: proc { draft? || copied_case.present? }

    after_validation do
      model.copied_case_id = nil
    end
  end
end
