require "rails_helper"

RSpec.describe RequiredDocumentCategoryAnalyser do
  before { DocumentCategoryPopulator.call }

  describe "#call" do
    subject(:call) { described_class.call(application) }

    context "when the application has dwp result overriden" do
      let(:dwp_override) { create(:dwp_override, :with_evidence) }
      let(:application) { create(:legal_aid_application, :with_applicant, dwp_override:) }

      context "when the provider has evidence of benefits" do
        it "updates the required_document_categories with benefit_evidence" do
          call
          expect(application.required_document_categories).to eq %w[benefit_evidence]
        end

        it "overwrites any existing required_document_categories" do
          application.update!(required_document_categories: %w[gateway_evidence])
          call
          expect(application.required_document_categories).to eq %w[benefit_evidence]
        end
      end

      context "when the provider has no evidence of benefits" do
        let(:dwp_override) { create(:dwp_override, :with_no_evidence) }

        it "does not update the required_document_categories with benefit_evidence" do
          call
          expect(application.required_document_categories).to be_empty
        end
      end
    end

    context "when the application has section 8 proceedings" do
      let(:application) { create(:legal_aid_application, :with_applicant, :with_multiple_proceedings_inc_section8) }

      it "updates the required_document_categories with gateway_evidence" do
        call
        expect(application.required_document_categories).to eq %w[gateway_evidence]
      end
    end

    context "when the application has dwp result overriden and section 8 proceedings" do
      let(:dwp_override) { create(:dwp_override, :with_evidence) }
      let(:application) { create(:legal_aid_application, :with_applicant, :with_multiple_proceedings_inc_section8, dwp_override:) }

      it "updates the required_document_categories with gateway_evidence" do
        call
        expect(application.required_document_categories).to eq %w[benefit_evidence gateway_evidence]
      end
    end

    context "when the application has neither dwp result overriden nor section 8 proceedings" do
      let(:application) { create(:legal_aid_application, :with_applicant) }

      it "updates the required_document_categories with an empty array" do
        call
        expect(application.required_document_categories).to eq []
      end
    end

    context "when the provider has entered employment details for the client" do
      let(:application) { create(:legal_aid_application, :with_employed_applicant_and_extra_info) }

      it "updates the required_document_categories with employment_evidence" do
        call
        expect(application.required_document_categories).to eq %w[client_employment_evidence]
      end
    end

    context "when the provider has entered employment details for the partner" do
      let(:application) { create(:legal_aid_application, :with_applicant, :with_employed_partner_and_extra_info) }

      it "updates the required_document_categories with part_employ_evidence" do
        call
        expect(application.required_document_categories).to eq %w[part_employ_evidence]
      end
    end

    context "when the application has a proceeding with opponent_application has_opponent_application true" do
      let(:application) { create(:legal_aid_application, :with_applicant, :with_opponents_application_proceeding) }

      it "updates the required_document_categories with court_application_or_order" do
        call
        expect(application.required_document_categories).to eq %w[court_application_or_order]
      end
    end

    context "when the application has a proceeding with final_hearing listed true" do
      let(:application) { create(:legal_aid_application, :with_applicant, :with_final_hearing_proceeding) }

      it "updates the required_document_categories with court_order and expert_report" do
        call
        expect(application.required_document_categories).to match_array %w[court_order expert_report]
      end
    end

    context "when the application has a proceeding with opponent_application has_opponent_application true and final_hearing listed true" do
      let(:application) { create(:legal_aid_application, :with_applicant, :with_opponents_application_proceeding, :with_final_hearing_proceeding) }

      it "updates the required_document_categories with court_order and expert_report" do
        call
        expect(application.required_document_categories).to match_array %w[court_application court_order expert_report]
      end
    end

    context "when the application is SCA and the client has parental_responsibility" do
      let(:application) { create(:legal_aid_application, :with_applicant) }

      before { create(:proceeding, :pb003, relationship_to_child:, legal_aid_application: application) }

      context "and have chosen parental responsibility" do
        let(:relationship_to_child) { "parental_responsibility_agreement" }

        it "updates the required_document_categories with parental_responsibility" do
          call
          expect(application.required_document_categories).to eq %w[parental_responsibility]
        end
      end

      context "and has chosen court_order" do
        let(:relationship_to_child) { "court_order" }

        it "updates the required_document_categories with parental_responsibility" do
          call
          expect(application.required_document_categories).to eq %w[parental_responsibility]
        end
      end
    end
  end
end
