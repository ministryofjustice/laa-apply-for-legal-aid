class BaseFileUploadForm # rubocop:disable Metrics/ClassLength
  include BaseForm

  attr_accessor :original_file, :provider_uploader, :upload_button_pressed

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

  validate :file_uploaded?
  validate :original_file_valid

  def exclude_from_model
    %i[upload_button_pressed original_file]
  end

  def save
    result = super
    return unless original_file

    # create and save statement_of_case model only if attachments were made
    model.save(validate: false) if attachments_made?
    # return result which returns 300 for redirect to fix tests
    result
  end

  def name
    @model.class.name.demodulize.underscore
  end

  def files?
    original_file.present?
  end

  private

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

  def too_big(original_file)
    return if original_file_size(original_file) <= BaseFileUploadForm.max_file_size

    error_options = { size: BaseFileUploadForm.max_file_size / 1.megabyte, file_name: @original_filename }
    errors.add(:original_file, original_file_error_for(:file_too_big, error_options))
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

  def original_file_error_for(error_type, options = {})
    error_path = @model.class.name.underscore.gsub('::', '/')
    I18n.t("activemodel.errors.models.#{error_path}.attributes.original_file.#{error_type}", **options)
  end

  def create_attachment(original_file)
    model.legal_aid_application.attachments.create document: original_file, attachment_type: name, original_filename: @original_file.original_filename,
                                                   attachment_name: sequenced_attachment_name
  end

  def sequenced_attachment_name
    if model.original_attachments.any?
      most_recent_name = model.original_attachments.order(:attachment_name).last.attachment_name
      increment_name(most_recent_name)
    else
      @name
    end
  end

  def increment_name(most_recent_name)
    if most_recent_name == name
      "#{name}_1"
    else
      most_recent_name =~ /^#{name}_(\d+)$/
      "#{name}_#{Regexp.last_match(1).to_i + 1}"
    end
  end
end
