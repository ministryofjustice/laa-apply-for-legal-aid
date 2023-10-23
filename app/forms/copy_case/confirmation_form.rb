module CopyCase
  class ConfirmationForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :copy_case_id, :copy_case_confirmation

    validates :copy_case_id, presence: true, unless: proc { draft? }
    validates :copy_case_confirmation, presence: true, unless: proc { draft? || copy_case_confirmation.present? }

    def save
      return false unless valid?

      cloner = CopyCase::ClonerService.new(legal_aid_application, copy_case_id)
      cloner.call
    end
    alias_method :save!, :save

    def exclude_from_model
      %i[copy_case_id copy_case_confirmation]
    end
  end
end
