# Add common file uploader methods to forms.
# Usage:
#   Add the following to the form:
#
#       include BaseFileUploaderForm
#
# Add it below the `include BaseForm`
# line so that it is included first

module BaseFileUploaderForm
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

  def self.included(base)
    super
    base.extend(ClassMethods)
    base.include(InstanceMethods)
  end

  module ClassMethods
    def max_file_size
      MAX_FILE_SIZE
    end
  end

  module InstanceMethods
    private

    def name
      @name ||= @model.class.name.demodulize.underscore
    end

    def too_big(original_file)
      return if original_file_size(original_file) <= self.class.max_file_size

      error_options = { size: self.class.max_file_size / 1.megabyte, file_name: @original_filename }
      errors.add(:original_file, original_file_error_for(:file_too_big, error_options))
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

      @original_filename = original_file.original_filename
      scanner_down(original_file)
      malware_scan(original_file)
      file_empty(original_file)
      disallowed_content_type(original_file)
      too_big(original_file)
      create_attachment(original_file) if errors.blank?
    end

    def create_attachment(original_file)
      model.legal_aid_application.attachments.create document: original_file,
                                                     attachment_type: name,
                                                     original_filename: @original_file.original_filename,
                                                     attachment_name: sequenced_attachment_name
    end

    def file_empty(original_file)
      return if File.size(original_file.tempfile) > 1

      errors.add(:original_file, original_file_error_for(:file_empty, file_name: @original_filename))
    end

    def disallowed_content_type(original_file)
      return if Marcel::Magic.by_magic(original_file)&.type.in?(ALLOWED_CONTENT_TYPES)
      return if original_file.content_type == WORD_DOCUMENT

      errors.add(:original_file, original_file_error_for(:content_type_invalid, file_name: @original_filename))
    end

    def scanner_down(original_file)
      return if malware_scan_result(original_file).scanner_working

      errors.add(:original_file, original_file_error_for(:system_down, file_name: @original_filename))
    end

    def malware_scan(original_file)
      return unless malware_scan_result(original_file).virus_found?

      errors.add(:original_file, original_file_error_for(:file_virus, file_name: @original_filename))
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
  end
end
