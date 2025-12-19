class BaseBankStatementForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  include MalwareScanning

  attr_reader :attachment_type, :attachment_type_capture

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

  WORD_DOCUMENT = "application/vnd.openxmlformats-officedocument.wordprocessingml.document".freeze
  CSV_DOCUMENT = "text/csv".freeze

  attr_accessor :original_file,
                :original_filename,
                :legal_aid_application_id,
                :upload_button_pressed

  validate :at_least_one_file_or_draft

  def self.max_file_size
    MAX_FILE_SIZE
  end

  def save_as_draft
    @draft = true
    save!
  end

  # Files already uploaded and created with bank statement associations
  # so we do not need to save anything at this point, only to validate that
  # there is one or more bank statements or the application is draft
  def save
    valid?
  end
  alias_method :save!, :save

  def upload
    return if original_file.nil?

    validate_original_file
    create_attachment(original_file) if errors.blank?
  end

  def legal_aid_application
    @legal_aid_application ||= LegalAidApplication.find(legal_aid_application_id)
  end

  def provider_uploader
    legal_aid_application.provider
  end

private

  def validate_original_file
    self.original_filename = original_file.original_filename
    scanner_down
    malware_scan
    file_empty
    disallowed_content_type
    too_big
  end

  def at_least_one_file_or_draft
    return if any_bank_statements_or_draft?

    @errors.add(:original_file, :no_file_chosen)
  end

  def draft?
    @draft
  end

  # can be shared with v1 bank statement controller
  def create_attachment(file)
    attachment = legal_aid_application
                    .attachments.create!(document: file,
                                         attachment_type:,
                                         original_filename: file.original_filename,
                                         attachment_name: sequenced_attachment_name)

    PDFConverterWorker.perform_async(attachment.id)
  end

  def too_big
    return if original_file_size(original_file) <= self.class.max_file_size

    error_options = { size: self.class.max_file_size / 1.megabyte, file_name: original_filename }
    errors.add(:original_file, :file_too_big, **error_options)
  end

  def file_empty
    return if File.size(original_file.tempfile) > 1

    errors.add(:original_file, :file_empty, file_name: original_filename)
  end

  def disallowed_content_type
    return if Marcel::Magic.by_magic(original_file)&.type.in?(ALLOWED_CONTENT_TYPES)
    # TODO: why isn't the file_type being caught in ALLOWED_CONTENT_TYPES?
    return if original_file.content_type == WORD_DOCUMENT
    return if original_file.content_type == CSV_DOCUMENT

    errors.add(:original_file, :content_type_invalid, file_name: original_filename)
  end

  def scanner_down
    return if malware_scan_result(original_file).scanner_working

    errors.add(:original_file, :system_down, file_name: original_filename)
  end

  def malware_scan
    return unless malware_scan_result(original_file).virus_found?

    errors.add(:original_file, :file_virus, file_name: original_filename)
  end

  def increment_name(most_recent_name)
    if most_recent_name == attachment_type
      "#{attachment_type}_1"
    else
      most_recent_name =~ attachment_type_capture
      "#{attachment_type}_#{Regexp.last_match(1).to_i + 1}"
    end
  end
end
