module CopyCase
  class ConfirmationForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :copied_case_id, :copy_case_confirmation

    validates :copied_case_id, presence: true, unless: :draft?
    validates :copy_case_confirmation, presence: true, unless: proc { draft? || copy_case_confirmation.present? }

    def save
      return if invalid? || draft? || !copy_case_confirmed?

      cloner = CopyCase::ClonerService.new(legal_aid_application, legal_aid_application_to_copy)
      cloner.call
    end
    alias_method :save!, :save

    def legal_aid_application_to_copy
      @legal_aid_application_to_copy ||= LegalAidApplication.find(copied_case_id)
    end

    def legal_aid_application
      @legal_aid_application ||= model
    end

    def copy_case_confirmed?
      copy_case_confirmation == "true"
    end
  end
end
