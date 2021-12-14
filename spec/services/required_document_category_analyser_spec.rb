require 'rails_helper'

RSpec.describe RequiredDocumentCategoryAnalyser do
  before { DocumentCategoryPopulator.call }

  describe '#call' do
    subject { described_class.call(application) }

    context 'application has dwp result overriden' do
      let(:application) { create :legal_aid_application, :with_dwp_override }
      it 'updates the required_document_categories with benefit_evidence' do
        subject
        expect(application.required_document_categories).to eq %w[benefit_evidence]
      end

      it 'overwrites any existing required_document_categories' do
        application.update!(required_document_categories: %w[gateway_evidence])
        subject
        expect(application.required_document_categories).to eq %w[benefit_evidence]
      end
    end

    context 'application has section 8 proceedings' do
      let(:application) { create :legal_aid_application, :with_multiple_proceedings_inc_section8 }
      it 'updates the required_document_categories with gateway_evidence' do
        subject
        expect(application.required_document_categories).to eq %w[gateway_evidence]
      end
    end

    context 'application has dwp result overriden and section 8 proceedings' do
      let(:application) { create :legal_aid_application, :with_dwp_override, :with_multiple_proceedings_inc_section8 }
      it 'updates the required_document_categories with gateway_evidence' do
        subject
        expect(application.required_document_categories).to eq %w[benefit_evidence gateway_evidence]
      end
    end

    context 'application has neither dwp result overriden nor section 8 proceedings' do
      let(:application) { create :legal_aid_application }
      it 'updates the required_document_categories with an empty array' do
        subject
        expect(application.required_document_categories).to eq []
      end
    end
  end
end
