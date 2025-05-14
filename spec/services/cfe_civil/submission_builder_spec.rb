require "rails_helper"

RSpec.describe CFECivil::SubmissionBuilder, :vcr do
  before do
    allow(Rails.configuration.x)
      .to receive(:cfe_civil_host)
        .and_return(staging_host)
  end

  let(:staging_host) { "https://cfe-civil-staging.cloud-platform.service.justice.gov.uk/" }

  describe ".call" do
    subject(:call) { described_class.call(legal_aid_application) }

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
             vehicles: build_list(:vehicle,
                                  1,
                                  estimated_value: 5_000,
                                  payment_remaining: 250,
                                  more_than_three_years_old: true,
                                  used_regularly: true),
             other_assets_declaration: build(:other_assets_declaration, :all_nil))
    end

    context "when HostEnv is not set" do
      before do
        allow(HostEnv).to receive(:environment).and_return(nil)
      end

      it "still generates the expected JSON but uses 'missing' in the header" do
        expect(call).to be_a CFE::V6::Result
      end
    end

    it "generates the expected JSON" do
      expect(call).to be_a CFE::V6::Result
    end

    it "does not save a submission object" do
      expect { call }.to change(CFE::Submission, :count).by 1
    end

    it "does not create a submission_history object" do
      expect { call }.to change(CFE::SubmissionHistory, :count).by 2
    end

    context "when sending data to CFE fails with a 422 error" do
      before do
        stub_request(:post, [staging_host, "v6/assessments"].join)
          .to_return(body: { errors: %w[fake_error] }.to_json, status: 422)
      end

      it "raises the expected error" do
        expect { call }.to raise_error(CFECivil::SubmissionError, /fake_error/)
      end
    end

    context "when cfe returns non json data" do
      before do
        stub_request(:post, [staging_host, "v6/assessments"].join)
          .to_return(body: "Boom!", status: 200)
      end

      it "raises the expected error" do
        expect { call }.to raise_error(JSON::ParserError, /^unexpected character: 'Boom!'/)
      end
    end
  end

  describe "#call" do
    subject(:call) { submission_builder.call }

    let(:submission_builder) { described_class.new(legal_aid_application) }

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
             vehicles: build_list(:vehicle,
                                  1,
                                  estimated_value: 5_000,
                                  payment_remaining: 250,
                                  more_than_three_years_old: true,
                                  used_regularly: true),
             other_assets_declaration: build(:other_assets_declaration, :all_nil))
    end

    context "when sending data to CFE fails with an unexpected error" do
      before do
        stub_request(:post, [staging_host, "v6/assessments"].join)
          .to_return(body: { errors: %w[rate_limiting] }.to_json, status: 424)
      end

      it "raises the expected error and marks the submission as failed" do
        expect { call }.to raise_error(CFECivil::SubmissionError, "Unsuccessful HTTP response code")
        expect(submission_builder.submission.failed?).to be true
      end
    end
  end
end
