require "rails_helper"

RSpec.describe CFE::CreateEmploymentsService do
  let(:submission) { create(:cfe_submission, aasm_state: "irregular_income_created", legal_aid_application: laa) }
  let(:service) { described_class.new(submission) }
  let(:laa) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, :employed) }
  let(:dummy_response) { dummy_response_hash.to_json }

  describe "#cfe_url" do
    it "contains the submission assessment id" do
      expected_url = "#{Rails.configuration.x.check_financial_eligibility_host}/assessments/#{submission.assessment_id}/employments"
      expect(service.cfe_url).to eq expected_url
    end
  end

  describe "#request_body" do
    context "applicant not employed" do
      let(:applicant) { create(:applicant, :not_employed) }

      it "returns empty payload" do
        expect(service.request_body).to eq empty_payload.to_json
      end
    end

    context "applicant employed" do
      let(:applicant) { create(:applicant, :employed) }
      let!(:employment) { create(:employment, :example1_usecase1, legal_aid_application: laa) }

      it "returns full payload" do
        expect(service.request_body).to eq full_payload.to_json
      end
    end
  end

  describe ".call" do
    before do
      stub_request(:post, service.cfe_url).with(body: expected_payload.to_json).to_return(body: dummy_response)
    end

    let(:applicant) { create(:applicant, :employed) }
    let(:expected_payload) { full_payload }
    let!(:employment) { create(:employment, :example1_usecase1, legal_aid_application: laa) }

    it "updates the state on the submission record from irregular_income_created to employments_created" do
      expect(submission.aasm_state).to eq "irregular_income_created"
      described_class.call(submission)
      expect(submission.aasm_state).to eq "employments_created"
    end

    it "creates a submission_history record" do
      expect {
        described_class.call(submission)
      }.to change { submission.submission_histories.count }.by 1
      history = CFE::SubmissionHistory.last
      expect(history.submission_id).to eq submission.id
      expect(history.url).to eq service.cfe_url
      expect(history.http_method).to eq "POST"
      expect(history.request_payload).to eq expected_payload.to_json
      expect(history.http_response_status).to eq 200
      expect(history.response_payload).to eq dummy_response
      expect(history.error_message).to be_nil
    end

    context "failed calls to CFE" do
      let(:expected_payload) { full_payload }
      let(:expected_payload_hash) { full_payload }

      before do
        create(:hmrc_response, :example1_usecase1, legal_aid_application: laa, owner_id: applicant.id, owner_type: applicant.class)
      end

      it_behaves_like "a failed call to CFE"
    end
  end

  def dummy_response_hash
    {
      success: true,
      errors: [],
    }
  end

  def empty_payload
    { employment_income: [] }
  end

  def full_payload
    {
      employment_income: [
        {
          name: "Job 788",
          client_id: "12345678-1234-1234-1234-123456789abc",
          payments: [
            {
              client_id: "20211128-0000-0000-0000-123456789abc",
              date: "2021-11-28",
              gross: 1868.98,
              benefits_in_kind: 0.0,
              tax: -161.8,
              national_insurance: -128.64,
              net_employment_income: 1578.54,
            },
            {
              client_id: "20211028-0000-0000-0000-123456789abc",
              date: "2021-10-28",
              gross: 1868.98,
              benefits_in_kind: 0.0,
              tax: -111.0,
              national_insurance: -128.64,
              net_employment_income: 1629.34,
            },
            {
              client_id: "20210928-0000-0000-0000-123456789abc",
              date: "2021-09-28",
              gross: 2492.61,
              benefits_in_kind: 0.0,
              tax: -286.6,
              national_insurance: -203.47,
              net_employment_income: 2002.54,
            },
            {
              client_id: "20210828-0000-0000-0000-123456789abc",
              date: "2021-08-28",
              gross: 2345.29,
              benefits_in_kind: 0.0,
              tax: -257.2,
              national_insurance: -185.79,
              net_employment_income: 1902.3,
            },
          ],
        },
      ],
    }
  end
end
