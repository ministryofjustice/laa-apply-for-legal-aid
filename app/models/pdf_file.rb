class PdfFile < ApplicationRecord
  has_one_attached :file

  def self.convert_original_file(original_file_id)
    return if exists?(original_file_id: original_file_id)

    PdfConverterWorker.perform_async(original_file_id)
  end
end
