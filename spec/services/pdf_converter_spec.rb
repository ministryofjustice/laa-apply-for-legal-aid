require 'rails_helper'

RSpec.describe PdfConverter do
  let(:statement_of_case) { create :statement_of_case }
  let(:file) { OpenStruct.new(name: 'hello_world.pdf', content_type: 'application/pdf') }
  let(:original_file) { statement_of_case.original_files.first }
  let(:filepath) { "#{Rails.root}/spec/fixtures/files/documents/#{file.name}" }
  let(:attachment) { statement_of_case.legal_aid_application.attachments.create!(attachment_type: 'statement_of_case', attachment_name: 'statement_of_case') }

  before do
    attachment.document.attach(io: File.open(filepath), filename: file.name, content_type: file.content_type)
  end

  subject do
    described_class.call(attachment.id)
  end

  describe '#call' do
    context 'original file is already a pdf' do
      it 'does not convert the file' do
        expect(Libreconv).not_to receive(:convert)
        subject
      end

      it 'creates an attachment record for the pdf' do
        expect { subject }.to change { Attachment.count }.by 1
      end
    end

    context 'original file is not a pdf' do
      let(:file) { OpenStruct.new(name: 'hello_world.docx', content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

      it 'converts the file to pdf' do
        expect(Libreconv).to receive(:convert)
        expect { subject }.to change { ActiveStorage::Attachment.count } .by(1)
        pdf_attachment = statement_of_case.pdf_attachments.first
        expect(pdf_attachment.attachment_name).to eq 'statement_of_case.pdf'
      end

      it 'relates the pdf record to the original file' do
        subject
        pdf_attachment = statement_of_case.pdf_attachments.first
        attachment = statement_of_case.original_attachments.first
        expect(attachment.pdf_attachment_id).to eq pdf_attachment.id
      end
    end
  end
end
