module CopyCase
  class ConfirmationForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :copy_case_id, :copy_case_confirmation

    validates :copy_case_id, presence: true, unless: :draft?
    validates :copy_case_confirmation, presence: true, unless: :draft?

    def save
      return if invalid? || draft?

      unless copy_case_confirmed?
        model.copy_case = nil
        model.copy_case_id = nil
        model.save!(validate: false)
        return
      end

      cloner = CopyCase::ClonerService.new(legal_aid_application, legal_aid_application_to_copy)
      cloner.call
    end
    alias_method :save!, :save

    def legal_aid_application_to_copy
      @legal_aid_application_to_copy ||= LegalAidApplication.find(copy_case_id)
    end

    def legal_aid_application
      @legal_aid_application ||= model
    end

    def copy_case_confirmed?
      copy_case_confirmation == "true"
    end
  end
end
