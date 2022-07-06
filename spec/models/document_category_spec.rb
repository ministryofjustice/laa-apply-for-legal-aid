require "rails_helper"

RSpec.describe DocumentCategory, type: :model do
  it {
    is_expected.to respond_to(:name,
                              :submit_to_ccms,
                              :ccms_document_type,
                              :display_on_evidence_upload,
                              :mandatory)
  }

  describe ".populate" do
    it "calls the document_category_populator service" do
      expect(DocumentCategoryPopulator).to receive(:call).with(no_args)
      described_class.populate
    end
  end

  describe ".displayable_document_category_names" do
    before { described_class.populate }

    let(:expected_categories) { %w[benefit_evidence employment_evidence gateway_evidence uncategorised] }

    it "returns an array of names to display on evidence upload page" do
      expect(described_class.displayable_document_category_names).to match_array(expected_categories)
    end
  end

  describe ".submittable_category_names" do
    before { described_class.populate }

    let(:expected_categories) do
      %w[
        bank_transaction_report
        bank_statement_evidence_pdf
        benefit_evidence_pdf
        employment_evidence_pdf
        gateway_evidence_pdf
        means_report
        merits_report
        statement_of_case_pdf
      ]
    end

    it "returns an array of names that should be uploaded to CCMS" do
      expect(described_class.submittable_category_names).to match_array(expected_categories)
    end
  end
end
