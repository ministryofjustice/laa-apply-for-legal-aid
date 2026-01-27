require "rails_helper"

module CCMS
  module Submitters
    RSpec.describe ObtainCaseReferenceService, :ccms do
      subject(:obtain_case_reference_service) { described_class.new(submission) }

      let(:legal_aid_application) { create(:legal_aid_application) }
      let(:submission) { create(:submission, legal_aid_application:) }
      let(:history) { SubmissionHistory.find_by(submission_id: submission.id) }
      let(:endpoint) { "https://ccms-soa-managed.laa-test.modernisation-platform.service.justice.gov.uk/soa-infra/services/default/GetReferenceData/getreferencedata_ep" }
      let(:response_body) { ccms_data_from_file "reference_data_response.xml" }

      around do |example|
        VCR.turned_off { example.run }
      end

      before do
        # stub a post request - any body, any headers
        stub_request(:post, endpoint).to_return(body: response_body, status: 200)
        # stub the transaction request id that we expect in the response
        allow_any_instance_of(CCMS::Requestors::ReferenceDataRequestor).to receive(:transaction_request_id).and_return("20190301030405123456")
      end

      context "when the operation is successful" do
        it "stores the reference number returned in the response_body" do
          obtain_case_reference_service.call
          expect(submission.case_ccms_reference).to eq "300000135140"
        end

        it "changes the state to case_ref_obtained" do
          obtain_case_reference_service.call
          expect(submission.aasm_state).to eq "case_ref_obtained"
        end

        it "writes a history record" do
          expect { obtain_case_reference_service.call }.to change(CCMS::SubmissionHistory, :count).by(1)

          expect(history.from_state).to eq "initialised"
          expect(history.to_state).to eq "case_ref_obtained"
          expect(history.success).to be true
          expect(history.details).to be_nil
        end

        it "writes the request body to the history record" do
          obtain_case_reference_service.call
          expect(history.request).to be_soap_envelope_with(
            command: "refdatabim:ReferenceDataInqRQ",
            transaction_id: "20190301030405123456",
          )
        end

        it "writes the response body to the history record" do
          obtain_case_reference_service.call
          expect(history.response).to eq response_body
        end
      end

      context "when the operation raises an error" do
        let(:error) { [CCMS::CCMSError, Faraday::Error, Faraday::SoapError, StandardError] }
        let(:fake_error) { error.sample } # TODO: avoid this pattern

        before do
          allow_any_instance_of(CCMS::Requestors::ReferenceDataRequestor).to receive(:call).and_raise(fake_error, "oops")
        end

        it "does not change the state" do
          expect { obtain_case_reference_service.call }.to raise_error(fake_error, "oops")
          expect(submission.aasm_state).to eq "initialised"
        end

        it "records the error in the submission history" do
          expect { obtain_case_reference_service.call }.to raise_error(fake_error, "oops")
          expect(CCMS::SubmissionHistory.count).to eq 1
          expect(history.from_state).to eq "initialised"
          expect(history.to_state).to eq "failed"
          expect(history.success).to be false
          expect(history.details).to match(/#{error}/)
          expect(history.details).to match(/oops/)
          expect(history.request).to be_soap_envelope_with(
            command: "refdatabim:ReferenceDataInqRQ",
            transaction_id: "20190301030405123456",
          )
          expect(history.response).to be_nil
        end
      end
    end
  end
end
