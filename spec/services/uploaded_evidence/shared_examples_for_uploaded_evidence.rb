RSpec.shared_examples "An uploaded evidence service" do
  describe "#attachment_type_options" do
    let(:legal_aid_application) { create(:legal_aid_application) }
    let(:controller) { instance_double Providers::UploadedEvidenceCollectionsController, legal_aid_application: }

    # exhaustive but unrealistic example
    let(:allowed_document_categories) do
      %w[benefit_evidence
         client_employment_evidence
         part_employ_evidence
         gateway_evidence
         court_application_or_order
         court_order
         court_application
         expert_report
         parental_responsibility
         local_authority_assessment
         grounds_of_appeal
         counsel_opinion
         judgement
         plf_court_order]
    end

    let(:expected_attachment_type_options) do
      [
        ["benefit_evidence", "Benefit evidence"],
        ["client_employment_evidence", "Client's employment evidence"],
        ["part_employ_evidence", "Partner's employment evidence"],
        ["gateway_evidence", "Gateway evidence"],
        ["court_application_or_order", "Court application or order"],
        ["court_order", "Court order"],
        ["court_application", "Court application"],
        ["expert_report", "Expert report"],
        ["parental_responsibility", "Parental responsibility evidence"],
        ["local_authority_assessment", "Assessment"],
        ["grounds_of_appeal", "Grounds of appeal"],
        ["counsel_opinion", "Counsel's opinion"],
        ["judgement", "Judgement"],
        ["plf_court_order", "Court order"],
        %w[uncategorised Uncategorised],
      ]
    end

    it "returns array of [key, value] arrays for contructing select list of document categories" do
      allow(legal_aid_application).to receive(:allowed_document_categories).and_return(allowed_document_categories)

      service = described_class.new(controller)
      expect(service.attachment_type_options).to eq expected_attachment_type_options
    end
  end
end
