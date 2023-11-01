module CopyCase
  class ConfirmationForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :copy_case_id, :copy_case_confirmation

    validates :copy_case_id, presence: true, unless: proc { draft? }
    validates :copy_case_confirmation, presence: true, unless: proc { draft? || copy_case_confirmation.present? }

    def save
      return false unless valid?

      # TODO: if they say no then delete procoeedings and redirect back to copy case invitation?
      # TODO: if they hit backpage we may need to delete cloned records??
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

    def exclude_from_model
      %i[copy_case_id copy_case_confirmation]
    end
  end
end
