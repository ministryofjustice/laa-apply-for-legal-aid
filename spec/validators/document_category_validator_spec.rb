require "rails_helper"

class DummyDocumentCategory
  include ActiveModel::Model
  include ActiveModel::Validations
  validates_with DocumentCategoryValidator
end

RSpec.describe DocumentCategoryValidator do
  context "with Attachment" do
    subject { Attachment.create! legal_aid_application: laa, attachment_type: }

    let(:laa) { create :legal_aid_application }
    let(:invalid_attachment_type) { "xxx-zzz" }
    let(:valid_attachment_types) { DocumentCategoryValidator::VALID_DOCUMENT_TYPES }

    context "with valid attachment types" do
      let(:attachment_type) { valid_attachment_types.sample }

      it "does not fail when trying to create a record with a valid attachment type" do
        record = subject
        expect(record).to be_instance_of(Attachment)
        expect(record).to be_valid
      end
    end

    context "with invalid attachment type" do
      let(:attachment_type) { invalid_attachment_type }

      it "fails when trying to create a record with an invalid attachment type" do
        expect { subject }.to raise_error ActiveRecord::RecordInvalid, "Validation failed: Attachment type 'xxx-zzz' is invalid"
      end
    end
  end

  context "with DocumentCategory" do
    subject { DocumentCategory.create! name: }

    let(:invalid_name) { "xxx-zzz" }
    let(:valid_names) { DocumentCategoryValidator::VALID_DOCUMENT_TYPES }

    context "with valid names" do
      let(:name) { valid_names.sample }

      it "does not fail when trying to create a record with an valid name" do
        record = subject
        expect(record).to be_instance_of(DocumentCategory)
        expect(record).to be_valid
      end
    end

    context "with an invalid attachment type" do
      let(:name) { invalid_name }

      it "fails when trying to create a record with an invalid attachment type" do
        expect { subject }.to raise_error ActiveRecord::RecordInvalid, "Validation failed: Name 'xxx-zzz' is invalid"
      end
    end
  end

  context "with DummyClass" do
    it "raises" do
      dummy = DummyDocumentCategory.new
      expect {
        dummy.valid?
      }.to raise_error ArgumentError, "Unexpected record sent to DocumentCategoryValidator"
    end
  end
end
