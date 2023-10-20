module CopyCase
  class ConfirmationForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :copy_case_id, :copy_case_confirmation

    validates :copy_case_id, presence: true, unless: proc { draft? }
    validates :copy_case_confirmation, presence: true, unless: proc { draft? || copy_case_confirmation.present? }

    def exclude_from_model
      %i[copy_case_id copy_case_confirmation]
    end
  end
end
