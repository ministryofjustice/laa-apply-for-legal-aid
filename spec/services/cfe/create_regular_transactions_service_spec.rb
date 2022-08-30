require "rails_helper"

RSpec.describe CFE::CreateRegularTransactionsService do
  let(:application) { create(:legal_aid_application, :with_applicant) }
  let(:service) { described_class.new(submission) }
  let(:submission) { create(:cfe_submission, aasm_state: "assessment_created", legal_aid_application: application) }
  let(:dummy_response) { { success: true }.to_json }

  describe "#cfe_url" do
    subject(:cfe_url) { service.cfe_url }

    let(:cfe_host) { Rails.configuration.x.check_financial_eligibility_host }

    it "returns expected endpoint path" do
      expect(cfe_url).to eq "#{cfe_host}/assessments/#{submission.assessment_id}/regular_transactions"
    end
  end

  describe "#request_body" do
    subject(:request_body) { service.request_body }

    let(:expected_payload) do
      {
        regular_transactions: [
          {
            category: "maintenance_in",
            operation: "credit",
            amount: 111.11,
            frequency: "monthly",
          },
          {
            category: "maintenance_out",
            operation: "debit",
            amount: 222.22,
            frequency: "monthly",
          },
        ],
      }
    end

    before do
      create(:regular_transaction,
             :maintenance_out,
             legal_aid_application: application,
             amount: 222.22,
             frequency: "monthly")
      create(:regular_transaction,
             :maintenance_in,
             legal_aid_application: application,
             amount: 111.11,
             frequency: "monthly")
    end

    it "creates the expected payload from the regular transaction records" do
      payload = JSON.parse(request_body, symbolize_names: true)

      expect(payload).to have_key(:regular_transactions)
      expect(payload[:regular_transactions]).to match_array(expected_payload[:regular_transactions])
    end
  end

  describe ".call" do
    subject(:call) { described_class.call(submission) }

    around do |example|
      VCR.turn_off!
      example.run
      VCR.turn_on!
    end

    context "when POST successful" do
      before do
        stub_request(:post, service.cfe_url)
          .with(body: expected_payload.to_json)
          .to_return(body: dummy_response)

        create(:regular_transaction, :maintenance_in, legal_aid_application: application, amount: 111.11, frequency: "monthly")
      end

      let(:expected_payload) do
        {
          regular_transactions: [
            {
              category: "maintenance_in",
              operation: "credit",
              amount: 111.11,
              frequency: "monthly",
            },
          ],
        }
      end

      it "updates the submission record from employments_created to regular_transactions_created" do
        expect { call }.to change(submission, :aasm_state).from("assessment_created").to("in_progress")
      end

      it "creates a submission_history record" do
        expect { call }.to change(submission.submission_histories, :count).by(1)

        expect(submission.submission_histories.last).to have_attributes(
          submission_id: submission.id,
          url: service.cfe_url,
          http_method: "POST",
          request_payload: expected_payload.to_json,
          http_response_status: 200,
          response_payload: dummy_response,
          error_message: nil,
        )
      end
    end

    describe "failed calls to CFE" do
      it_behaves_like "a failed call to CFE"
    end
  end
end
