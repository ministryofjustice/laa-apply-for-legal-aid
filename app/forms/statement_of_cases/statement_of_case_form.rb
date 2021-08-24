module StatementOfCases
  class StatementOfCaseForm
    include BaseForm
    include BaseFileUploaderForm

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
      model.save(validate: false) if attachments_made?
      # return result which returns 300 for redirect to fix tests
      result
    end

    private

    def statement_present_or_file_uploaded
      return if file_present_or_draft?

      @errors.add(:original_file, :blank) if statement.blank?
    end

    def file_present_or_draft?
      model.original_attachments.any? || original_file.present? || draft?
    end

    def original_file_error_for(error_type, options = {})
      I18n.t("activemodel.errors.models.application_merits_task/statement_of_case.attributes.original_file.#{error_type}", **options)
    end

    def create_attachment(original_file)
      model.legal_aid_application.attachments.create document: original_file, attachment_type: 'statement_of_case', original_filename: original_filename,
                                                     attachment_name: sequenced_attachment_name
    end

    def sequenced_attachment_name
      if model.original_attachments.any?
        most_recent_name = model.original_attachments.order(:attachment_name).last.attachment_name
        increment_name(most_recent_name)
      else
        'statement_of_case'
      end
    end

    def increment_name(most_recent_name)
      if most_recent_name == 'statement_of_case'
        'statement_of_case_1'
      else
        most_recent_name =~ /^statement_of_case_(\d+)$/
        "statement_of_case_#{Regexp.last_match(1).to_i + 1}"
      end
    end
  end
end
