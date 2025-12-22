module PDF
  class ConvertFile
    def initialize(source_temp_file)
      @source_temp_file = source_temp_file
    end

    def self.call(source_temp_file)
      new(source_temp_file).call
    end

    def call
      file = Tempfile.new
      Libreconv.convert(@source_temp_file.path, file.path)
      file.close
      file
    end
  end
end
