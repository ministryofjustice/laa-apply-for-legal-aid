require "rails_helper"

RSpec.describe HMRC::Interface::ResultService do
  subject(:submission_result) { described_class.new(hmrc_response) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { legal_aid_application.applicant }
  let(:hmrc_response) { create(:hmrc_response, :in_progress, owner_id: applicant.id, owner_type: applicant.class) }
  let(:expected_body) do
    {
      submission: hmrc_response.submission_id,
      status: "completed",
      data: [
        { correlation_id: hmrc_response.submission_id },
        {
          "individuals/matching/individual": {
            firstName: "fname",
            lastName: "lname",
            nino: "XY234567A",
            dateOfBirth: "1992-07-22",
          },
        },
        { "income/paye/paye": { income: [] } },
        { "income/sa/selfAssessment": [] },
        { "income/sa/pensions_and_state_benefits/selfAssessment": [] },
        { "income/sa/source/selfAssessment": [] },
        { "income/sa/employments/selfAssessment": [] },
        { "income/sa/additional_information/selfAssessment": [] },
        { "income/sa/partnerships/selfAssessment": [] },
        { "income/sa/uk_properties/selfAssessment": [] },
        { "income/sa/foreign/selfAssessment": [] },
        { "income/sa/further_details/selfAssessment": [] },
        { "income/sa/interests_and_dividends/selfAssessment": [] },
        { "income/sa/other/selfAssessment": [] },
        { "income/sa/summary/selfAssessment": [] },
        { "income/sa/trusts/selfAssessment": [] },
        { "employments/paye/employments": [] },
        { "benefits_and_credits/working_tax_credit/applications": [] },
        { "benefits_and_credits/child_tax_credit/applications": [] },
      ],
    }
  end
  let(:expected_status) { 200 }

  before do
    stub_request(:post, %r{(http|https).*laa-hmrc-interface.*\.cloud-platform\.service\.justice\.gov\.uk/oauth/token})
      .to_return(
        status: 200,
        body: '{"access_token":"test-bearer-token","token_type":"Bearer","expires_in":7200,"created_at":1582809000}',
        headers: { "Content-Type" => "application/json; charset=utf-8" },
      )
    stub_request(:get, %r{http.*laa-hmrc-interface.*.cloud-platform.service.justice.gov.uk/api/v1/submission/result/#{hmrc_response.submission_id}})
      .to_return(
        status: expected_status,
        body: expected_body.to_json,
        headers: { "Content-Type" => "application/json; charset=utf-8" },
      )
  end

  describe "#call" do
    subject(:call) { described_class.call(hmrc_response) }

    it { is_expected.to eql expected_body }
  end

  describe ".call" do
    subject(:call) { submission_result.call }

    context "when the submission has completed successfully" do
      it { is_expected.to eql expected_body }
    end

    context "when the submission is still in progress" do
      let(:expected_status) { 202 }
      let(:expected_body) do
        {
          submission: hmrc_response.submission_id,
          status: "in_progress",
          _links: [
            {
              href: "https://main-laa-hmrc-interface-uat.cloud-platform.service.justice.gov.uk/api/v1/submission/status/#{hmrc_response.submission_id}",
            },
          ],
        }
      end

      it "does not raise an error" do
        expect { call }.not_to raise_error
      end
    end

    context "when the submission has failed" do
      let(:expected_status) { 202 }
      let(:expected_body) do
        {
          submission: hmrc_response.submission_id,
          status: "failed",
          data: [
            { correlation_id: hmrc_response.submission_id },
            { error: "submitted client details could not be found in HMRC service" },
          ],
        }
      end

      it "does not raise an error" do
        expect { call }.not_to raise_error
      end

      it { is_expected.to eql expected_body }
    end

    context "when an error occurs in the result process" do
      let(:get_url) { %r{(http|https).*laa-hmrc-interface.*\.cloud-platform\.service\.justice\.gov\.uk/api/v1/submission/result/.*} }

      before do
        stub_request(:get, get_url)
          .to_raise(StandardError)
      end

      context "and the http status is 422" do
        before do
          stub_request(:get, get_url)
            .to_return(body: error_response, status: 422)
        end

        it "raises an exception" do
          expect { call }.to raise_error HMRC::InterfaceError, /Couldn't find ProceedingType/
        end
      end

      context "and the http status is failing" do
        before do
          stub_request(:get, get_url)
            .to_return(body: "", status: 503)
        end

        it "raises an exception" do
          expect {
            described_class.call(hmrc_response)
          }.to raise_error HMRC::InterfaceError, /Bad Request: URL:/
        end
      end

      def error_response
        {
          success: false,
          error_class: "ActiveRecord::RecordNotFound",
          message: "Couldn't find ProceedingType",
          backtrace: ["fake error backtrace"],
        }.to_json
      end
    end
  end
end
