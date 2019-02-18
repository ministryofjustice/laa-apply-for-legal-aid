module StatementOfCases
  class PdfConverter
    def self.call(statement_of_case)
      new(statement_of_case).call
    end

    attr_reader :statement_of_case

    def initialize(statement_of_case)
      @statement_of_case = statement_of_case
    end

    def call
      statement_of_case.pdf_file.attach(
        io: File.open(converted_file.path),
        filename: "#{statement_of_case.original_file.filename.base}.pdf",
        content_type: 'application/pdf'
      )
    end

    private

    def converted_file
      ActiveStoragePdfConverter.call(statement_of_case.original_file)
    end
  end
end
