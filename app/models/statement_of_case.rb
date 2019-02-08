class StatementOfCase < ApplicationRecord
  belongs_to :legal_aid_application
  has_one_attached :original_file

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

  validates_presence_of :statement, unless: :file_present?
  validate :original_file_too_big
  validate :original_file_empty
  validate :original_file_disallowed_content_type

  def self.max_file_size
    MAX_FILE_SIZE
  end

  private

  def original_file_too_big
    return unless file_present?
    return if original_file.blob.byte_size <= StatementOfCase.max_file_size

    errors.add(:original_file, original_file_error_for(:file_too_big, size: StatementOfCase.max_file_size / 1.megabyte))
  end

  def original_file_empty
    return unless file_present?
    return if original_file.blob.byte_size > 1

    errors.add(:original_file, original_file_error_for(:file_empty))
  end

  def original_file_disallowed_content_type
    return unless file_present?
    return if original_file.blob.content_type.in?(ALLOWED_CONTENT_TYPES)

    errors.add(:original_file, original_file_error_for(:content_type_invalid))
  end

  def file_present?
    original_file.attachment.present?
  end

  def original_file_error_for(error_type, options = {})
    I18n.t("activerecord.errors.models.statement_of_case.attributes.original_file.#{error_type}", options)
  end
end
