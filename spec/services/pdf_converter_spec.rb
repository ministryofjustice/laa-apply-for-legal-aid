require "rails_helper"

FileStruct = Struct.new(:name, :content_type)

RSpec.describe PdfConverter do
  subject do
    described_class.call(attachment.id)
  end

  before { allow(Libreconv).to receive(:convert) }

  context "when attachment is statement of case" do
    let(:statement_of_case) { create(:statement_of_case) }
    let(:file) { FileStruct.new("hello_world.pdf", "application/pdf") }
    let(:original_file) { statement_of_case.original_files.first }
    let(:filepath) { Rails.root.join("spec/fixtures/files/documents/#{file.name}").to_s }
    let(:attachment) { statement_of_case.legal_aid_application.attachments.create!(attachment_type: "statement_of_case", attachment_name: "statement_of_case") }

    before do
      attachment.document.attach(io: File.open(filepath), filename: file.name, content_type: file.content_type)
    end

    describe "#call" do
      context "original file is already a pdf" do
        it "does not convert the file" do
          expect(Libreconv).not_to receive(:convert)
          subject
        end

        it "creates an attachment record for the pdf" do
          expect { subject }.to change(Attachment, :count).by 1
        end
      end

      context "original file is not a pdf" do
        let(:file) { FileStruct.new("hello_world.docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document") }

        it "converts the file to pdf" do
          expect(Libreconv).to receive(:convert)
          expect { subject }.to change(ActiveStorage::Attachment, :count).by(1)
          pdf_attachment = statement_of_case.pdf_attachments.first
          expect(pdf_attachment.attachment_name).to eq "statement_of_case.pdf"
        end

        it "relates the pdf record to the original file" do
          subject
          pdf_attachment = statement_of_case.pdf_attachments.first
          attachment = statement_of_case.original_attachments.first
          expect(attachment.pdf_attachment_id).to eq pdf_attachment.id
        end

        context "when there are multiple uploaded files" do
          let(:attachment) { statement_of_case.legal_aid_application.attachments.create!(attachment_type: "statement_of_case", attachment_name: "statement_of_case_2") }

          it "converts the file to pdf" do
            expect(Libreconv).to receive(:convert)
            expect { subject }.to change(ActiveStorage::Attachment, :count).by(1)
            pdf_attachment = statement_of_case.pdf_attachments.first
            expect(pdf_attachment.attachment_name).to eq "statement_of_case_2.pdf"
            expect(pdf_attachment.attachment_type).to eq "statement_of_case_pdf"
          end

          it "relates the pdf record to the original file" do
            subject
            pdf_attachment = statement_of_case.pdf_attachments.first
            attachment = statement_of_case.original_attachments.first
            expect(attachment.pdf_attachment_id).to eq pdf_attachment.id
          end
        end
      end
    end
  end

  context "when attachment is gateway evidence" do
    let(:gateway_evidence) { create(:gateway_evidence) }
    let(:file) { FileStruct.new("hello_world.pdf", "application/pdf") }
    let(:original_file) { gateway_evidence.original_files.first }
    let(:filepath) { Rails.root.join("spec/fixtures/files/documents/#{file.name}").to_s }
    let(:attachment) { gateway_evidence.legal_aid_application.attachments.create!(attachment_type: "gateway_evidence", attachment_name: "gateway_evidence") }

    before do
      attachment.document.attach(io: File.open(filepath), filename: file.name, content_type: file.content_type)
    end

    describe "#call" do
      context "original file is already a pdf" do
        it "does not convert the file" do
          expect(Libreconv).not_to receive(:convert)
          subject
        end

        it "creates an attachment record for the pdf" do
          expect { subject }.to change(Attachment, :count).by 1
        end
      end

      context "original file is not a pdf" do
        let(:file) { FileStruct.new("hello_world.docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document") }

        it "converts the file to pdf" do
          expect(Libreconv).to receive(:convert)
          expect { subject }.to change(ActiveStorage::Attachment, :count).by(1)
          pdf_attachment = gateway_evidence.pdf_attachments.first
          expect(pdf_attachment.attachment_name).to eq "gateway_evidence.pdf"
        end

        it "relates the pdf record to the original file" do
          subject
          pdf_attachment = gateway_evidence.pdf_attachments.first
          attachment = gateway_evidence.original_attachments.first
          expect(attachment.pdf_attachment_id).to eq pdf_attachment.id
        end

        context "when there are multiple uploaded files" do
          let(:attachment) { gateway_evidence.legal_aid_application.attachments.create!(attachment_type: "gateway_evidence", attachment_name: "gateway_evidence_2") }

          it "converts the file to pdf" do
            expect(Libreconv).to receive(:convert)
            expect { subject }.to change(ActiveStorage::Attachment, :count).by(1)
            pdf_attachment = gateway_evidence.pdf_attachments.first
            expect(pdf_attachment.attachment_name).to eq "gateway_evidence_2.pdf"
            expect(pdf_attachment.attachment_type).to eq "gateway_evidence_pdf"
          end

          it "relates the pdf record to the original file" do
            subject
            pdf_attachment = gateway_evidence.pdf_attachments.first
            attachment = gateway_evidence.original_attachments.first
            expect(attachment.pdf_attachment_id).to eq pdf_attachment.id
          end
        end
      end
    end
  end
end
