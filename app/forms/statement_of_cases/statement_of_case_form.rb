module StatementOfCases
  class StatementOfCaseForm < BaseFileUploadForm
    form_for ApplicationMeritsTask::StatementOfCase

    attr_accessor :statement

    validate :statement_present_or_file_uploaded

    def exclude_from_model
      %i[upload_button_pressed original_file]
    end

    private

    def statement_present_or_file_uploaded
      return if file_present_or_draft?

      @errors.add(:original_file, :blank) if statement.blank?
    end

    def file_present_or_draft?
      model.original_attachments.any? || original_file.present? || draft?
    end
  end
end
