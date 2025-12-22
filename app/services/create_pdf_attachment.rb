class CreatePDFAttachment
  def self.call(attachment_id)
    new(attachment_id).call
  end

  attr_reader :attachment_id

  def initialize(attachment_id)
    @attachment_id = attachment_id
    @original_attachment = Attachment.find_by(id: attachment_id)
  end

  def call
    return if @original_attachment&.pdf_attachment_id.present?

    file = converted_file
    raise_alarm_for(file.size) if file.size > 8_000_000

    Attachment.transaction do
      pdf_filename = "#{File.basename(@original_attachment.attachment_name, '.*')}.pdf"
      pdf_attachment = Attachment.create!(
        legal_aid_application_id: @original_attachment.legal_aid_application_id,
        attachment_type: "#{File.basename(@original_attachment.attachment_type, '.*')}_pdf",
        attachment_name: pdf_filename,
      )
      pdf_attachment.document.attach(
        io: File.open(file.path),
        filename: pdf_filename,
        content_type: "application/pdf",
      )
      @original_attachment.update!(pdf_attachment_id: pdf_attachment.id)
    end
  end

private

  def converted_file
    return downloaded_file if @original_attachment.document.content_type == "application/pdf"

    PDF::ConvertFile.call(downloaded_file)
  end

  def downloaded_file
    @downloaded_file ||= original_attachment_download
  end

  def original_attachment_download
    file = Tempfile.new
    file.binmode
    file.write(@original_attachment.document.download)
    file.close
    file
  end

  def raise_alarm_for(file_size)
    message = "FileSizeWarning: attachment #{@original_attachment.id} converted to #{(file_size.to_f / 1_000_000).round(2)}MB"
    Rails.logger.error(message)
    Sentry.capture_message(message)
  end
end
