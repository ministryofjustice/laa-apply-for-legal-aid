class PdfConverter
  def self.call(pdf_file_id)
    new(pdf_file_id).call
  end

  attr_reader :pdf_file_id

  def initialize(pdf_file_id)
    @pdf_file_id = pdf_file_id
  end

  def call
    return unless pdf_file # pdf_file may have been deleted on original file being deleted

    file = converted_file
    return unless PdfFile.exists?(pdf_file_id) # Check still there on completion of conversion

    pdf_file.file.attach(
      io: File.open(file.path),
      filename: "#{original_attachment.filename.base}.pdf",
      content_type: 'application/pdf'
    )
  end

  private

  def pdf_file
    PdfFile.find_by(id: pdf_file_id)
  end
  delegate :original_file_id, to: :pdf_file

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
