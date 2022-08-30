require "rails_helper"

module CFE
  RSpec.describe CreateProceedingTypesService do
    let(:application) { create(:legal_aid_application, :with_positive_benefit_check_result, transaction_period_finish_on: Time.zone.today) }
    let(:submission) { create(:cfe_submission, aasm_state: "assessment_created", legal_aid_application: application) }
    let(:dummy_response) { dummy_response_hash.to_json }
    let(:service) { described_class.new(submission) }

    before do
      create(:proceeding, :da001, legal_aid_application: application, client_involvement_type_ccms_code: "Z")
      create(:proceeding, :se013, legal_aid_application: application, client_involvement_type_ccms_code: "A")
    end

    describe "#cfe_url" do
      it "contains the submission assessment id" do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_financial_eligibility_host}/assessments/#{submission.assessment_id}/proceeding_types"
      end
    end

    describe "#request payload" do
      it "creates the expected payload from the values in the applicant" do
        expect(service.request_body).to eq expected_payload_hash.to_json
      end
    end

    describe ".call" do
      around do |example|
        VCR.turn_off!
        example.run
        VCR.turn_on!
      end

      context "with response received from CFE" do
        describe "successful post" do
          before do
            stub_request(:post, service.cfe_url)
              .with(body: service.request_body)
              .to_return(body: dummy_response)
          end

          it "updates the state on the submission record from assessment_created to to in_progress" do
            expect(submission.aasm_state).to eq "assessment_created"
            described_class.call(submission)
            expect(submission.aasm_state).to eq "in_progress"
          end

          it "creates a submission_history record" do
            expect {
              described_class.call(submission)
            }.to change { submission.submission_histories.count }.by 1
            history = CFE::SubmissionHistory.last
            expect(history.submission_id).to eq submission.id
            expect(history.url).to eq service.cfe_url
            expect(history.http_method).to eq "POST"
            expect(history.request_payload).to eq service.request_body
            expect(history.http_response_status).to eq 200
            expect(history.response_payload).to eq dummy_response
            expect(history.error_message).to be_nil
          end
        end

        context "with unsuccessful_response_from_CFE" do
          it_behaves_like "a failed call to CFE"
        end
      end

      describe "failed calls to CFE" do
        it_behaves_like "a failed call to CFE"
      end
    end

    def expected_payload_hash
      {
        proceeding_types: [
          {
            ccms_code: "DA001",
            client_involvement_type: "Z",
          },
          {
            ccms_code: "SE013",
            client_involvement_type: "A",
          },
        ],
      }
    end

    def dummy_response_hash
      {
        success: true,
      }
    end
  end
end
