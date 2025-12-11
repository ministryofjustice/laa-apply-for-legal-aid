class PdfConverter
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

    # Libreconv.convert(source, target, soffice_command = nil, convert_to = nil)
    #
    # libreoffice \
    #   --headless \
    #   --convert-to pdf:writer_pdf_Export \
    #   --image-resolution=150 \
    #   --image-compression=jpeg \
    #   --image-quality=70 \
    #   input.docx

    file = Tempfile.new
    # Libreconv.convert(downloaded_file.path, file.path)
    # Libreconv.convert(downloaded_file.path, file.path, nil, "pdf:writer_pdf_Export --image-resolution=150 --image-compression=jpeg --image-quality=70") # =>Error: "Error: Please verify input parameters...
    # Libreconv.convert(downloaded_file.path, file.path, nil, "pdf:writer_pdf_Export") # No size difference observed without image options
    # Libreconv.convert(downloaded_file.path, file.path, nil, "pdf:writer_pdf_Export:ReduceImageResolution=true;MaxImageResolution=150;SelectPdfVersion=1;Quality=80;CompressImages=true;ExportBookmarks=false;UseTaggedPDF=false;EmbedStandardFonts=false;SubsetFonts=false;ExportFormFields=false;CreateTaggedPDF=false;UseLosslessCompression=false;ExportNotes=false") # No size difference observed without image options
    # Libreconv.convert(downloaded_file.path, file.path, nil, "pdf:writer_pdf_Export:SelectPdfVersion=2;ReduceImageResolution=true;MaxImageResolution=150;Quality=60;ExportNotes=false;UseTaggedPDF=false;ExportBookmarks=false") # Suggested by chatgpt, failed with either a "Task policy set failed: 4 ((os/kern) invalid argument)" error or a libreconv failed error depending on soffice verion and type of install

    # cmd = [
    #   "soffice", # use which soffice
    #   "--headless",
    #   "--nologo",
    #   "--nolockcheck",
    #   "--norestore",
    #   "--nofirststartwizard",
    #   "--convert-to",
    #   "pdf:writer_pdf_Export:SelectPdfVersion=2;ReduceImageResolution=true;MaxImageResolution=150;Quality=60;UseTaggedPDF=false;ExportBookmarks=false;ExportNotes=false",
    #   "--outdir",
    #   File.dirname(file.path),
    #   downloaded_file.path,
    # ] # No error but pdf is empty :(

    cmd = [
      "soffice", # use which soffice
      "--headless",
      "--convert-to",
      "pdf",
      "--outdir",
      File.dirname(file.path),
      downloaded_file.path,
    ]

    system(*cmd) # No error but pdf is empty :(

    file.close
    file
  end

  def downloaded_file
    file = Tempfile.new
    file.binmode
    file.write(@original_attachment.document.download)
    file.close
    file
  end
end
