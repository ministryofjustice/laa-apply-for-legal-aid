class ActiveStoragePdfConverter
  def self.call(active_storage_file)
    new(active_storage_file).call
  end

  attr_reader :active_storage_file

  def initialize(active_storage_file)
    @active_storage_file = active_storage_file
  end

  def call
    # no need to convert the file if it is already a PDF
    return downloaded_file if active_storage_file.content_type == 'application/pdf'

    converted_file
  end

  private

  def converted_file
    file = Tempfile.new
    Libreconv.convert(downloaded_file.path, file.path)
    file
  end

  def downloaded_file
    file = Tempfile.new
    file.binmode
    file.write(active_storage_file.download)
    file.close
    file
  end
end
