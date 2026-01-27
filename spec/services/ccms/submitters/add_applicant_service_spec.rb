require "rails_helper"

module CCMS
  module Submitters
    RSpec.describe AddApplicantService, :ccms do
      subject(:instance) { described_class.new(submission) }

      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_address, :with_merits_submitted) }
      let(:applicant) { legal_aid_application.applicant }
      let(:address) { applicant.home_address_for_ccms }
      let(:submission) { create(:submission, :case_ref_obtained, legal_aid_application:) }
      let(:history) { SubmissionHistory.find_by(submission_id: submission.id) }
      let(:endpoint) { "https://ccms-soa-managed.laa-test.modernisation-platform.service.justice.gov.uk/soa-infra/services/default/ClientServices/ClientServices_ep" }
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
            instance.call
            expect(submission.aasm_state).to eq "applicant_submitted"
          end

          it "records the transaction id of the request" do
            instance.call
            expect(submission.applicant_add_transaction_id).to eq "20190301030405123456"
          end

          it "writes a history record" do
            instance.call
            expect(history).to have_attributes(from_state: "case_ref_obtained",
                                               to_state: "applicant_submitted",
                                               success: true,
                                               response: kind_of(String),
                                               details: nil)
          end

          it "stores the reqeust body in the submission history record" do
            instance.call
            expect(history.request).to be_soap_envelope_with(
              command: "clientbim:ClientAddRQ",
              transaction_id: "20190301030405123456",
              matching: [
                "<common:Surname>#{applicant.last_name}</common:Surname>",
                "<common:FirstName>#{applicant.first_name}</common:FirstName>",
                "<common:AddressLine1>#{address.address_line_one}</common:AddressLine1>",
                "<common:AddressLine2>#{address.address_line_two}</common:AddressLine2>",
                "<common:City>#{address.city}</common:City>",
                "<common:PostalCode>#{address.postcode}</common:PostalCode>",
              ],
            )
          end

          it "stores the response body in the submission history record" do
            instance.call
            expect(history.response).to eq response_body
          end
        end
      end

      context "when the operation is in error" do
        context "and it errors when adding an applicant" do
          let(:error) { [CCMS::CCMSError, Faraday::Error, Faraday::SoapError, StandardError] }
          let(:sample_error) { error.sample }

          before do
            allow_any_instance_of(CCMS::Requestors::ApplicantAddRequestor).to receive(:call).and_raise(sample_error, "oops")
          end

          it "does not change submission state" do
            expect { instance.call }.to raise_error(sample_error)
            expect(submission.reload.aasm_state).to eq "case_ref_obtained"
          end

          it "records the error in the submission history" do
            expect { instance.call }.to raise_error(sample_error)

            expect(history).to have_attributes(from_state: "case_ref_obtained",
                                               to_state: "failed",
                                               success: false,
                                               response: nil,
                                               details: /#{sample_error}.*oops/m)

            expect(history.request).to be_soap_envelope_with(
              command: "clientbim:ClientAddRQ",
              transaction_id: "20190301030405123456",
              matching: [
                "<common:Surname>#{applicant.last_name}</common:Surname>",
                "<common:FirstName>#{applicant.first_name}</common:FirstName>",
                "<common:AddressLine1>#{address.address_line_one}</common:AddressLine1>",
                "<common:AddressLine2>#{address.address_line_two}</common:AddressLine2>",
                "<common:City>#{address.city}</common:City>",
                "<common:PostalCode>#{address.postcode}</common:PostalCode>",
              ],
            )
          end
        end

        context "when the response is unsuccessful from CCMS adding an applicant" do
          let(:response_body) { ccms_data_from_file "applicant_add_response_failure.xml" }

          it "does not change state" do
            expect { instance.call }.to raise_error(CCMS::CCMSUnsuccessfulResponseError, "AddApplicantService failed with unsuccessful response for submission: #{submission.id}")
            expect(submission.aasm_state).to eq "case_ref_obtained"
          end

          it "records the error in the submission history" do
            expect { instance.call }.to raise_error(CCMS::CCMSUnsuccessfulResponseError, "AddApplicantService failed with unsuccessful response for submission: #{submission.id}")
            expect(history).to have_attributes(from_state: "case_ref_obtained",
                                               to_state: "failed",
                                               success: false,
                                               response: kind_of(String),
                                               details: /CCMS::CCMSUnsuccessfulResponseError.*AddApplicantService failed with unsuccessful response for submission: #{submission.id}/m)
          end

          it "stores the reqeust body in the submission history record" do
            expect { instance.call }.to raise_error(CCMS::CCMSUnsuccessfulResponseError, "AddApplicantService failed with unsuccessful response for submission: #{submission.id}")
            expect(history.request).to be_soap_envelope_with(
              command: "clientbim:ClientAddRQ",
              transaction_id: "20190301030405123456",
              matching: [
                "<common:Surname>#{applicant.last_name}</common:Surname>",
                "<common:FirstName>#{applicant.first_name}</common:FirstName>",
                "<common:AddressLine1>#{address.address_line_one}</common:AddressLine1>",
                "<common:AddressLine2>#{address.address_line_two}</common:AddressLine2>",
                "<common:City>#{address.city}</common:City>",
                "<common:PostalCode>#{address.postcode}</common:PostalCode>",
              ],
            )
          end

          it "stores the response body in the submission history record" do
            expect { instance.call }.to raise_error(CCMS::CCMSUnsuccessfulResponseError, "AddApplicantService failed with unsuccessful response for submission: #{submission.id}")
            expect(history.response).to eq response_body
          end
        end
      end
    end
  end
end
