class PdfConverter
  def self.call(original_file_id)
    new(original_file_id).call
  end

  attr_reader :original_file_id

  def initialize(original_file_id)
    @original_file_id = original_file_id
  end

  def call
    pdf_file.file.attach(
      io: File.open(converted_file.path),
      filename: "#{original_attachment.filename.base}.pdf",
      content_type: 'application/pdf'
    )
  end

  private

  def pdf_file
    PdfFile.find_or_create_by!(original_file_id: original_file_id)
  end

  def converted_file
    return downloaded_file if original_attachment.content_type == 'application/pdf'

    file = Tempfile.new
    Libreconv.convert(downloaded_file.path, file.path)
    file.close
    file
  end

  def downloaded_file
    file = Tempfile.new
    file.binmode
    file.write(original_attachment.download)
    file.close
    file
  end

  def original_attachment
    @original_attachment ||= ActiveStorage::Attachment.find(original_file_id)
  end
end
