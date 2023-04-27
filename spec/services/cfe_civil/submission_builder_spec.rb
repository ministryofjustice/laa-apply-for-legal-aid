require "rails_helper"

RSpec.describe CFECivil::SubmissionBuilder, :vcr do
  describe ".call" do
    subject(:call) { described_class.call(legal_aid_application, save_result:) }

    let(:legal_aid_application) do
      create(:legal_aid_application,
             :with_everything,
             :with_proceedings,
             :with_positive_benefit_check_result,
             :applicant_entering_means,
             property_value: 841_157.03,
             outstanding_mortgage_amount: 963_023.55,
             shared_ownership: true,
             percentage_home: 38.47,
             vehicle: build(:vehicle,
                            estimated_value: 5_000,
                            payment_remaining: 250,
                            purchased_on: Date.new(2023, 1, 10),
                            used_regularly: true),
             other_assets_declaration: build(:other_assets_declaration, :all_nil))
    end
    let(:staging_host) { "https://main-cfe-civil-uat.cloud-platform.service.justice.gov.uk/" }
    let(:save_result) { true } # this is for once we switch to using CFECivil permanently

    before do
      allow(Rails.configuration.x).to receive(:cfe_civil_host).and_return(staging_host)
    end

    context "when not saving the result" do
      let(:save_result) { false } # this is only while running comparison

      it "generates the expected JSON" do
        expect(call).to be_a CFE::Submission
      end

      it "does not save a submission object" do
        expect { call }.not_to change(CFE::Submission, :count)
      end

      it "does not create a submission_history object" do
        expect { call }.not_to change(CFE::SubmissionHistory, :count)
      end
    end

    context "when saving the result" do
      it "generates the expected JSON" do
        expect(call).to be_a CFE::V6::Result
      end

      it "does not save a submission object" do
        expect { call }.to change(CFE::Submission, :count).by 1
      end

      it "does not create a submission_history object" do
        expect { call }.to change(CFE::SubmissionHistory, :count).by 2
      end
    end

    context "when sending data to CFE fails with a 422 error" do
      before do
        stub_request(:post, [staging_host, "v6/assessments"].join).to_return(body: { errors: %w[fake_error] }.to_json, status: 422)
      end

      it "raises the expected error" do
        expect { call }.to raise_error(CFECivil::SubmissionError, /fake_error/)
      end
    end

    context "when cfe returns non json data" do
      before do
        stub_request(:post, [staging_host, "v6/assessments"].join).to_return(body: "Boom!", status: 200)
      end

      it "raises the expected error" do
        expect { call }.to raise_error(JSON::ParserError, "unexpected token at 'Boom!'")
      end
    end
  end

  describe "#call" do
    subject(:call) { submission_builder.call }

    let(:submission_builder) { described_class.new(legal_aid_application, save_result:) }
    let(:legal_aid_application) do
      create(:legal_aid_application,
             :with_everything,
             :with_proceedings,
             :with_positive_benefit_check_result,
             :applicant_entering_means,
             property_value: 841_157.03,
             outstanding_mortgage_amount: 963_023.55,
             shared_ownership: true,
             percentage_home: 38.47,
             vehicle: build(:vehicle,
                            estimated_value: 5_000,
                            payment_remaining: 250,
                            purchased_on: Date.new(2023, 1, 10),
                            used_regularly: true),
             other_assets_declaration: build(:other_assets_declaration, :all_nil))
    end
    let(:staging_host) { "https://main-cfe-civil-uat.cloud-platform.service.justice.gov.uk/" }
    let(:save_result) { true } # this is for once we switch to using CFECivil permanently

    context "when sending data to CFE fails with an unexpected error" do
      before do
        stub_request(:post, [staging_host, "v6/assessments"].join).to_return(body: { errors: %w[rate_limiting] }.to_json, status: 424)
      end

      it "raises the expected error and marks the submission as failed" do
        expect { call }.to raise_error(CFECivil::SubmissionError, "Unsuccessful HTTP response code")
        expect(submission_builder.submission.failed?).to be true
      end
    end
  end
end
