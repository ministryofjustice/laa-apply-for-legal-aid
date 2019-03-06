class PdfFile < ApplicationRecord
  has_one_attached :file

  def self.convert_original_file(original_file_id)
    return if original_file_id.nil? || exists?(original_file_id: original_file_id)

    pdf_file = create!(original_file_id: original_file_id)
    PdfConverterWorker.perform_async(pdf_file.id)
  end
end
