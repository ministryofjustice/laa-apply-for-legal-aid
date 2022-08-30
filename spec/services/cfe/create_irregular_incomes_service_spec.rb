require "rails_helper"

module CFE
  RSpec.describe CreateIrregularIncomesService do
    let(:application) { create(:legal_aid_application, :with_negative_benefit_check_result) }
    let(:submission) { create(:cfe_submission, aasm_state: "assessment_created", legal_aid_application: application) }
    let!(:irregular_income) { create(:irregular_income, legal_aid_application: application, amount: 3628.07) }
    let(:service) { described_class.new(submission) }

    describe "#cfe_url" do
      it "contains the submission assessment id" do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_financial_eligibility_host}/assessments/#{submission.assessment_id}/irregular_incomes"
      end
    end

    describe "#request_body" do
      it "is as expected" do
        service = described_class.new(submission)
        expect(service.request_body).to eq expected_payload
      end
    end

    describe ".call" do
      before do
        stub_request(:post, service.cfe_url).with(body: expected_payload).to_return(body: dummy_response)
      end

      it "sends expected payload to configured endpoint" do
        described_class.call(submission)

        expect(
          a_request(:post, service.cfe_url)
            .with(body: expected_payload),
        ).to have_been_made.once
      end

      it "progresses the submission state" do
        described_class.call(submission)
        expect(submission.reload.aasm_state).to eq "in_progress"
      end
    end

    def expected_payload
      {
        payments: [
          {
            income_type: "student_loan",
            frequency: "annual",
            amount: 3628.07,
          },
        ],
      }.to_json
    end

    def dummy_response
      {
        success: true,
        errors: [],
      }.to_json
    end
  end
end
