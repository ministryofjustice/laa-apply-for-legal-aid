require "rails_helper"

RSpec.describe DocumentCategory do
  describe ".populate" do
    it "calls the document_category_populator service" do
      expect(DocumentCategoryPopulator).to receive(:call).with(no_args)
      described_class.populate
    end
  end

  describe ".displayable_document_category_names" do
    before { described_class.populate }

    let(:expected_categories) do
      %w[
        benefit_evidence
        client_employment_evidence
        part_employ_evidence
        gateway_evidence
        uncategorised
        court_application_or_order
        court_application
        court_order
        expert_report
        parental_responsibility
      ]
    end

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
        client_employment_evidence_pdf
        part_employ_evidence_pdf
        gateway_evidence_pdf
        means_report
        merits_report
        statement_of_case_pdf
        court_application_or_order_pdf
        court_application_pdf
        court_order_pdf
        expert_report_pdf
        part_bank_state_evidence_pdf
        parental_responsibility_pdf
      ]
    end

    it "returns an array of names that should be uploaded to CCMS" do
      expect(described_class.submittable_category_names).to match_array(expected_categories)
    end
  end
end
