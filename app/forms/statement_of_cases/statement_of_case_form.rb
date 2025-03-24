module StatementOfCases
  class StatementOfCaseForm < BaseFileUploaderForm
    form_for ApplicationMeritsTask::StatementOfCase

    attr_accessor :statement, :original_file, :original_filename, :provider_uploader, :upload_button_pressed

    def exclude_from_model
      %i[upload_button_pressed original_file original_filename]
    end

    validate :statement_present_or_file_uploaded
    validate :file_uploaded?
    validate :original_file_valid

    def save
      result = super
      return unless original_file

      # create and save statement_of_case model only if attachments were made
      model.save!(validate: false) if attachments_made?
      # return result which returns 300 for redirect to fix tests
      result
    end
    alias_method :save!, :save

  private

    def statement_present_or_file_uploaded
      return if file_present_or_draft?

      @errors.add(:statement, :blank) if statement.blank?
    end

    def file_present_or_draft?
      model.original_attachments.any? || original_file.present? || draft?
    end
  end
end
