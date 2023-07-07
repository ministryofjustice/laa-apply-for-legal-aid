require "rails_helper"

RSpec.describe AttachmentsHelper do
  let(:application) { create(:legal_aid_application) }

  describe "#attachments_with_size" do
    context "with attachments" do
      let!(:statement_of_case) { create(:statement_of_case, :with_original_file_attached, legal_aid_application: application) }
      let(:attachments) { statement_of_case.original_attachments }

      it "returns array of file names with their file size" do
        expect(attachments_with_size(attachments)).to eq ["Fake file name 1 (15.7 KB)"]
      end
    end

    context "without attachments" do
      let(:attachments) { nil }

      it "returns empty array" do
        expect(attachments_with_size(attachments)).to eq []
      end
    end

    context "without original_filename" do
      let(:attachment1) { create(:attachment, original_filename: nil) }
      let(:attachment2) { create(:attachment, original_filename: "fake name") }
      let(:attachments) { [attachment1, attachment2] }

      it "returns attachment_type name in its place" do
        expect(attachments_with_size(attachments)).to contain_exactly("statement_of_case (15.7 KB)", "fake name (15.7 KB)")
      end
    end
  end
end
