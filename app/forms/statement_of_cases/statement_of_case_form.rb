module StatementOfCases
  class StatementOfCaseForm
    include BaseForm

    form_for StatementOfCase

    attr_accessor :statement, :original_file, :provider_uploader

    MAX_FILE_SIZE = 50.megabytes

    ALLOWED_CONTENT_TYPES = %w[
      application/pdf
      application/msword
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
      application/vnd.oasis.opendocument.text
      text/rtf
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

    validates :statement, presence: true, unless: :file_present_or_draft?
    validate :original_file_too_big
    validate :original_file_empty
    validate :original_file_disallowed_content_type
    validate :original_file_malware_scan

    private

    def file_present_or_draft?
      file_present? || draft?
    end

    def original_file_too_big
      return unless file_present?
      return if original_file_size <= StatementOfCaseForm.max_file_size

      errors.add(:original_file, original_file_error_for(:file_too_big, size: StatementOfCaseForm.max_file_size / 1.megabyte))
    end

    def original_file_empty
      return unless file_present?
      return if File.size(original_file.tempfile) > 1

      errors.add(:original_file, original_file_error_for(:file_empty))
    end

    def original_file_disallowed_content_type
      return unless file_present?
      return if original_file.content_type.in?(ALLOWED_CONTENT_TYPES)

      errors.add(:original_file, original_file_error_for(:content_type_invalid))
    end

    def original_file_malware_scan
      return unless file_present?

      return unless malware_scan_result.virus_found?

      errors.add(:original_file, original_file_error_for(:file_virus))
    end

    def file_present?
      original_file.present?
    end

    def malware_scan_result
      @malware_scan_result ||= MalwareScanner.call(
        file_path: original_file.tempfile.path,
        uploader: provider_uploader,
        file_details: {
          size: original_file_size,
          name: original_file.original_filename,
          content_type: original_file.content_type
        }
      )
    end

    def original_file_size
      @original_file_size ||= File.size(original_file.tempfile)
    end

    def original_file_error_for(error_type, options = {})
      I18n.t("activemodel.errors.models.statement_of_case.attributes.original_file.#{error_type}", options)
    end
  end
end
