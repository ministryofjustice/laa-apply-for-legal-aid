require 'rails_helper'

RSpec.describe PdfConverter do
  let(:statement_of_case) { create :statement_of_case }
  let(:file) { OpenStruct.new(name: 'hello_world.pdf', content_type: 'application/pdf') }
  let(:original_file) { statement_of_case.original_files.first }
  let(:pdf_file) { PdfFile.last }

  before do
    filepath = "#{Rails.root}/spec/fixtures/files/documents/#{file.name}"
    statement_of_case.original_files.attach(io: File.open(filepath), filename: file.name, content_type: file.content_type)
  end

  subject do
    described_class.call(original_file.id)
  end

  describe '#call' do
    it 'creates a PdfFile record with the same base name' do
      expect { subject }.to change { PdfFile.count } .by(1)
      expect(pdf_file.file.filename.base).to eq(original_file.filename.base)
      expect(pdf_file.file.content_type).to eq('application/pdf')
    end

    context 'original file is already a pdf' do
      it 'does not convert the file' do
        expect(Libreconv).not_to receive(:convert)
        subject
      end
    end

    context 'original file is not a pdf' do
      let(:file) { OpenStruct.new(name: 'hello_world.docx', content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

      it 'converts the file to pdf' do
        expect(Libreconv).to receive(:convert)
        expect { subject }.to change { PdfFile.count } .by(1)
        expect(pdf_file.file.filename.base).to eq(original_file.filename.base)
        expect(pdf_file.file.content_type).to eq('application/pdf')
      end
    end
  end
end
