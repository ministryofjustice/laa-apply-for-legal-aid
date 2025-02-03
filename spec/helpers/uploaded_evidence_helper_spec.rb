require "rails_helper"

RSpec.describe UploadedEvidenceHelper do
  before do
    DocumentCategoryPopulator.call
  end

  describe ".evidence_message" do
    subject(:evidence_message) { helper.evidence_message(legal_aid_application, evidence_type_translation) }

    let(:legal_aid_application) { create(:legal_aid_application, required_document_categories:) }
    let(:required_document_categories) { %w[client_employment_evidence] }
    let(:evidence_type_translation) { nil }

    context "when there is only one required document category" do
      context "and there are section 8 proceedings" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8, required_document_categories:) }

        it { is_expected.to have_css("div.govuk-body", text: "Use this page to upload gateway evidence. This is optional.") }
      end

      context "and evidence_type_translation is present" do
        let(:evidence_type_translation) { "Universal Credit" }
        let(:required_document_categories) { %w[client_employment_evidence] }

        it { is_expected.to have_css("div.govuk-body", text: "Use this page to upload Universal Credit.") }
      end

      context "and it is not section 8 and evidence_type_translation is not present" do
        let(:required_document_categories) { %w[client_employment_evidence] }

        it { is_expected.to have_css("div.govuk-body", text: "Use this page to upload evidence of your client's employment.") }
      end
    end

    context "when there is more than one required document category" do
      let(:required_document_categories) { %w[client_employment_evidence local_authority_assessment] }

      it "renders the correct html" do
        expect(evidence_message).to have_css("div.govuk-body", text: "Use this page to upload:")
        expect(evidence_message).to have_css("ul") do |item|
          expect(item).to have_css("li", text: "evidence of your client's employment")
          expect(item).to have_css("li", text: "evidence of the local authority's assessment")
        end
      end
    end
  end
end
