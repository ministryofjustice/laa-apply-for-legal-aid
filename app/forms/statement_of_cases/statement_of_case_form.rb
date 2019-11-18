module StatementOfCases
  class StatementOfCaseForm # rubocop:disable Metrics/ClassLength
    include BaseForm

    form_for StatementOfCase

    attr_accessor :statement, :original_files, :provider_uploader, :upload_button_pressed

    MAX_FILE_SIZE = 8.megabytes

    ALLOWED_CONTENT_TYPES = %w[
      application/pdf
      application/msword
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
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

    def self.max_file_size
      MAX_FILE_SIZE
    end

    def exclude_from_model
      %i[upload_button_pressed original_files]
    end

    validates :statement, presence: true, unless: :file_present_or_draft?
    validate :original_files_valid

    def save
      super
    end

    private

    def original_files_valid
      if @upload_button_pressed == true
        if original_files.nil? || original_files.none?
          errors.add(:original_files, original_file_error_for(:no_file_chosen))
          return
        end
      end
      original_files&.each do |original_file|
        original_file_too_big(original_file)
        original_file_empty(original_file)
        original_file_malware_scan(original_file)
        original_file_disallowed_content_type(original_file)
        create_attachment(original_file)
      end
    end

    def file_present_or_draft?
      model.original_attachments.any? || original_files&.any? || draft?
    end

    def original_file_too_big(original_file)
      return unless file_present?(original_file)
      return if original_file_size(original_file) <= StatementOfCaseForm.max_file_size

      errors.add(:original_files, original_file_error_for(:file_too_big, size: StatementOfCaseForm.max_file_size / 1.megabyte))
    end

    def original_file_empty(original_file)
      return unless file_present?(original_file)
      return if File.size(original_file.tempfile) > 1

      errors.add(:original_files, original_file_error_for(:file_empty))
    end

    def original_file_disallowed_content_type(original_file)
      return unless file_present?(original_file)
      return if original_file.content_type.in?(ALLOWED_CONTENT_TYPES)

      errors.add(:original_files, original_file_error_for(:content_type_invalid))
    end

    def original_file_malware_scan(original_file)
      return unless file_present?(original_file)

      return unless malware_scan_result(original_file).virus_found?

      errors.add(:original_files, original_file_error_for(:file_virus))
    end

    def file_present?(original_file)
      original_file.present?
    end

    def malware_scan_result(original_file)
      @malware_scan_result ||= MalwareScanner.call(
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
      I18n.t("activemodel.errors.models.statement_of_case.attributes.original_files.#{error_type}", options)
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
