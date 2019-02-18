require 'rails_helper'

RSpec.describe StatementOfCases::PdfConverter do
  let(:statement_of_case) { create :statement_of_case }
  let(:file_base_name) { 'hello_world' }
  let(:original_file_name) { "#{file_base_name}.docx" }
  let(:pdf_file_name) { "#{file_base_name}.pdf" }

  subject { described_class.call(statement_of_case) }

  before do
    statement_of_case.original_file.attach(
      io: File.open(Rails.root.join("spec/fixtures/files/documents/#{original_file_name}")),
      filename: original_file_name
    )
  end

  describe '#call' do
    it 'convert the original file and creates a new pdf_file' do
      expect(Libreconv).to receive(:convert)
      expect { subject }.to change { statement_of_case.pdf_file.attachment.present? } .from(false).to(true)
      expect(statement_of_case.pdf_file.blob.filename.to_s).to eq(pdf_file_name)
      expect(statement_of_case.pdf_file.blob.content_type).to eq('application/pdf')
    end

    context 'original file is already a pdf' do
      let(:original_file_name) { pdf_file_name }

      it 'copies the original_file to pdf_file' do
        expect { subject }.to change { statement_of_case.pdf_file.attachment.present? } .from(false).to(true)
        expect(statement_of_case.pdf_file.blob.filename.to_s).to eq(pdf_file_name)
        expect(statement_of_case.pdf_file.blob.content_type).to eq('application/pdf')
        expect(statement_of_case.pdf_file.blob.checksum).to eq(statement_of_case.original_file.blob.checksum)
      end

      it 'does not convert the file' do
        expect(Libreconv).not_to receive(:convert)
        subject
      end
    end
  end
end
