module StatementOfCases
  class StatementOfCaseForm # rubocop:disable Metrics/ClassLength
    include BaseForm

    form_for ApplicationMeritsTask::StatementOfCase

    attr_accessor :statement, :original_file, :provider_uploader, :upload_button_pressed

    MAX_FILE_SIZE = 7.megabytes

    ALLOWED_CONTENT_TYPES = %w[
      application/pdf
      application/msword
      application/vnd.oasis.opendocument.text
      text/rtf
      text/plain
      application/rtf
      image/jpeg
      image/png
      image/tiff
      image/bmp
      image/x-bitmap
    ].freeze

    WORD_DOCUMENT = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'.freeze

    def self.max_file_size
      MAX_FILE_SIZE
    end

    def exclude_from_model
      %i[upload_button_pressed original_file]
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

    def attachments_made?
      model.legal_aid_application.attachments.present?
    end

    def file_uploaded?
      return true unless @upload_button_pressed == true && original_file.nil?

      errors.add(:original_file, original_file_error_for(:no_file_chosen))
    end

    def original_file_valid
      return if original_file.nil?

      @original_file_name = original_file.original_filename
      scanner_down(original_file)
      malware_scan(original_file)
      file_empty(original_file)
      disallowed_content_type(original_file)
      too_big(original_file)
      create_attachment(original_file) if errors.blank?
    end

    def file_present_or_draft?
      model.original_attachments.any? || original_file.present? || draft?
    end

    def too_big(original_file)
      return if original_file_size(original_file) <= StatementOfCaseForm.max_file_size

      error_options = { size: StatementOfCaseForm.max_file_size / 1.megabyte, file_name: @original_file_name }
      errors.add(:original_file, original_file_error_for(:file_too_big, error_options))
    end

    def file_empty(original_file)
      return if File.size(original_file.tempfile) > 1

      errors.add(:original_file, original_file_error_for(:file_empty, file_name: @original_file_name))
    end

    def disallowed_content_type(original_file)
      return if Marcel::Magic.by_magic(original_file)&.type.in?(ALLOWED_CONTENT_TYPES)
      return if original_file.content_type == WORD_DOCUMENT

      errors.add(:original_file, original_file_error_for(:content_type_invalid, file_name: @original_file_name))
    end

    def scanner_down(original_file)
      return if malware_scan_result(original_file).scanner_working

      errors.add(:original_file, original_file_error_for(:system_down, file_name: @original_file_name))
    end

    def malware_scan(original_file)
      return unless malware_scan_result(original_file).virus_found?

      errors.add(:original_file, original_file_error_for(:file_virus, file_name: @original_file_name))
    end

    def malware_scan_result(original_file)
      MalwareScanner.call(
        file_path: original_file.tempfile.path,
        uploader: provider_uploader,
        file_details: {
          size: original_file_size(original_file),
          name: original_file.original_filename,
          content_type: original_file.content_type
        }
      )
    end

    def original_file_size(original_file)
      File.size(original_file.tempfile)
    end

    def original_file_error_for(error_type, options = {})
      I18n.t("activemodel.errors.models.application_merits_task/statement_of_case.attributes.original_file.#{error_type}", **options)
    end

    def create_attachment(original_file)
      model.legal_aid_application.attachments.create document: original_file, attachment_type: 'statement_of_case', attachment_name: sequenced_attachment_name
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
