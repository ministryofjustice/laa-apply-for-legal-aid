require 'rails_helper'

RSpec.describe DocumentCategory, type: :model do
  it {
    is_expected.to respond_to(:name,
                              :submit_to_ccms,
                              :ccms_document_type,
                              :display_on_evidence_upload,
                              :mandatory)
  }

  describe '.populate' do
    it 'calls the document_category_populator service' do
      expect(DocumentCategoryPopulator).to receive(:call).with(no_args)
      described_class.populate
    end
  end
end
