require "rails_helper"

module CCMS
  module Submitters
    RSpec.describe AddApplicantService, :ccms do
      subject { described_class.new(submission) }

      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_address) }
      let(:applicant) { legal_aid_application.applicant }
      let(:address) { applicant.address }
      let(:submission) { create(:submission, :case_ref_obtained, legal_aid_application:) }
      let(:history) { SubmissionHistory.find_by(submission_id: submission.id) }
      let(:endpoint) { "https://ccmssoagateway.dev.legalservices.gov.uk/ccmssoa/soa-infra/services/default/ClientServices/ClientServices_ep" }
      let(:response_body) { ccms_data_from_file "applicant_add_response_success.xml" }

      around do |example|
        VCR.turn_off!
        example.run
        VCR.turn_on!
      end

      before do
        # stub a post request - any body, any headers
        stub_request(:post, endpoint).to_return(body: response_body, status: 200)

        # stub the transaction request id that we expect in the response
        allow_any_instance_of(CCMS::Requestors::ApplicantAddRequestor).to receive(:transaction_request_id).and_return("20190301030405123456")
      end

      context "when the operation is successful" do
        context "and no applicant exists on the CCMS system" do
          it "sets state to applicant_submitted" do
            subject.call
            expect(submission.aasm_state).to eq "applicant_submitted"
          end

          it "records the transaction id of the request" do
            subject.call
            expect(submission.applicant_add_transaction_id).to eq "20190301030405123456"
          end

          it "writes a history record" do
            expect { subject.call }.to change(CCMS::SubmissionHistory, :count).by(1)
            expect(history.from_state).to eq "case_ref_obtained"
            expect(history.to_state).to eq "applicant_submitted"
            expect(history.success).to be true
            expect(history.details).to be_nil
          end

          it "stores the reqeust body in the submission history record" do
            subject.call
            expect(history.request).to be_soap_envelope_with(
              command: "clientbim:ClientAddRQ",
              transaction_id: "20190301030405123456",
              matching: [
                "<common:Surname>#{applicant.last_name}</common:Surname>",
                "<common:FirstName>#{applicant.first_name}</common:FirstName>",
                "<common:AddressLine1>#{address.first_lines}</common:AddressLine1>",
                "<common:City>#{address.city}</common:City>",
                "<common:PostalCode>#{address.postcode}</common:PostalCode>",
              ],
            )
          end

          it "stores the response body in the submission history record" do
            subject.call
            expect(history.response).to eq response_body
          end
        end
      end

      context "when the operation is in error" do
        context "and it errors when adding an applicant" do
          let(:error) { [CCMS::CCMSError, Savon::Error, StandardError] }

          before do
            sample_error = error.sample
            expect_any_instance_of(CCMS::Requestors::ApplicantAddRequestor).to receive(:call).and_raise(sample_error, "oops")
            expect { subject.call }.to raise_error(sample_error)
          end

          it "does not change submission state" do
            expect(submission.reload.aasm_state).to eq "case_ref_obtained"
          end

          it "records the error in the submission history" do
            submission_history = submission.submission_history
            expect(submission_history.count).to eq 1
            expect(history.from_state).to eq "case_ref_obtained"
            expect(history.to_state).to eq "failed"
            expect(history.success).to be false
            expect(history.details).to match(/#{error}/)
            expect(history.details).to match(/oops/)
            expect(history.response).to be_nil
            expect(history.request).to be_soap_envelope_with(
              command: "clientbim:ClientAddRQ",
              transaction_id: "20190301030405123456",
              matching: [
                "<common:Surname>#{applicant.last_name}</common:Surname>",
                "<common:FirstName>#{applicant.first_name}</common:FirstName>",
                "<common:AddressLine1>#{address.first_lines}</common:AddressLine1>",
                "<common:City>#{address.city}</common:City>",
                "<common:PostalCode>#{address.postcode}</common:PostalCode>",
              ],
            )
          end
        end

        context "when the response is unsuccessful from CCMS adding an applicant" do
          let(:response_body) { ccms_data_from_file "applicant_add_response_failure.xml" }

          before do
            expect { subject.call }.to raise_error(CCMS::CCMSUnsuccessfulResponseError, "AddApplicantService failed with unsuccessful response for submission: #{submission.id}")
          end

          it "does not change state" do
            expect(submission.aasm_state).to eq "case_ref_obtained"
          end

          it "records the error in the submission history" do
            submission_history = submission.reload.submission_history
            expect(submission_history.count).to eq 1
            expect(history.from_state).to eq "case_ref_obtained"
            expect(history.to_state).to eq "failed"
            expect(history.success).to be false
          end

          it "stores the reqeust body in the submission history record" do
            expect(history.request).to be_soap_envelope_with(
              command: "clientbim:ClientAddRQ",
              transaction_id: "20190301030405123456",
              matching: [
                "<common:Surname>#{applicant.last_name}</common:Surname>",
                "<common:FirstName>#{applicant.first_name}</common:FirstName>",
                "<common:AddressLine1>#{address.first_lines}</common:AddressLine1>",
                "<common:City>#{address.city}</common:City>",
                "<common:PostalCode>#{address.postcode}</common:PostalCode>",
              ],
            )
          end

          it "stores the response body in the submission history record" do
            expect(history.response).to eq response_body
          end
        end
      end
    end
  end
end
