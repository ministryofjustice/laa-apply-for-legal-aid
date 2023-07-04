require "rails_helper"

RSpec.describe HMRC::Interface::SubmissionService do
  subject(:interface) { described_class.new(hmrc_response) }

  before do
    stub_request(:post, %r{(http|https).*laa-hmrc-interface.*\.cloud-platform\.service\.justice\.gov\.uk/oauth/token})
      .to_return(
        status: 200,
        body: '{"access_token":"test-bearer-token","token_type":"Bearer","expires_in":7200,"created_at":1582809000}',
        headers: { "Content-Type" => "application/json; charset=utf-8" },
      )
    stub_request(:post, %r{(http|https).*laa-hmrc-interface.*\.cloud-platform\.service\.justice\.gov\.uk/api/v1/submission/create/.*})
      .to_return(
        status: 202,
        body: '{"id":"26b94ef2-5854-409a-8223-05f4b58368b7","_links":[{"href":"https://main-laa-hmrc-interface-uat.cloud-platform.service.justice.gov.uk/api/v1/submission/status/26b94ef2-5854-409a-8223-05f4b58368b7"}]
}',
        headers: { "Content-Type" => "application/json; charset=utf-8" },
      )
  end

  let(:application) { create(:legal_aid_application, :with_applicant, :with_transaction_period) }
  let(:applicant) { application.applicant }
  let(:use_case) { "one" }
  let(:hmrc_response) { create(:hmrc_response, :use_case_one, legal_aid_application: application, owner_id: applicant.id, owner_type: applicant.class) }

  describe ".call" do
    subject(:call) { interface.call }

    it "returns the a json string" do
      expect(call.keys).to match_array %i[id _links]
    end

    context "when the number of months is changed" do
      before { allow(Rails.configuration.x.hmrc_interface).to receive(:duration_check).and_return("4") }

      let(:start_date) { Time.zone.today - 4.months }

      it "honours the date values" do
        call
        expect(a_request(:post, %r{.*/api/v1/submission/create/.*}).with { |req| req.body.include?(start_date.strftime("%Y-%m-%d")) }).to have_been_made
      end
    end

    context "when an error occurs in the submission process" do
      before do
        stub_request(:post, %r{(http|https).*laa-hmrc-interface.*\.cloud-platform\.service\.justice\.gov\.uk/api/v1/submission/create/.*})
          .to_raise(StandardError)
      end

      context "http status 422" do
        before do
          stub_request(:post, interface.hmrc_interface_url)
            .with(body: interface.request_body)
            .to_return(body: error_response, status: 422)
        end

        it "raises an exception" do
          expect { call }.to raise_error HMRC::InterfaceError, /Couldn't find ProceedingType/
        end
      end

      context "other failing http status" do
        before do
          stub_request(:post, interface.hmrc_interface_url)
            .with(body: interface.request_body)
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

  describe "#call" do
    subject(:call) { described_class.call(hmrc_response) }

    it "returns the expected json string" do
      expect(call.keys).to match_array %i[id _links]
    end
  end
end
