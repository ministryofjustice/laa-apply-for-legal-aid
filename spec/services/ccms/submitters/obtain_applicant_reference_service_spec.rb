require "rails_helper"

module CCMS
  module Submitters
    RSpec.describe ObtainApplicantReferenceService, :ccms do
      subject(:instance) { described_class.new(submission) }

      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, :with_everything_and_address, :with_merits_submitted, applicant:, populate_vehicle: true) }
      let(:applicant) { create(:applicant, :with_address, first_name: "Amy", last_name: "Williams", date_of_birth: Date.new(1972, 1, 1), national_insurance_number: "QQ123456A") }
      let(:submission) { create(:submission, :case_ref_obtained, legal_aid_application:) }
      let(:histories) { CCMS::SubmissionHistory.where(submission_id: submission.id).order(:created_at) }
      let(:latest_history) { histories.reload.last }
      let(:request_body) { ccms_data_from_file "applicant_search_request.xml" }
      let(:response_body) { ccms_data_from_file "applicant_search_responses/one_result_match.xml" }
      let(:empty_response_body) { ccms_data_from_file "applicant_search_response_no_results.xml" }
      let(:no_applicant_details_response_body) { ccms_data_from_file "applicant_search_response_results_no_details.xml" }
      let(:endpoint) { "https://ccms-soa-managed.laa-test.modernisation-platform.service.justice.gov.uk/soa-infra/services/default/ClientServices/ClientServices_ep" }
      let(:success_add_applicant_response_body) { ccms_data_from_file "applicant_add_response_success.xml" }

      around do |example|
        VCR.turn_off!
        example.run
        VCR.turn_on!
      end

      before do
        # stub the transaction request id that we expect in the response
        allow_any_instance_of(CCMS::Requestors::ApplicantSearchRequestor).to receive(:transaction_request_id).and_return("20190301030405123456")
      end

      context "when the operation is successful" do
        context "and the applicant exists on the CCMS system" do
          before do
            stub_request(:post, endpoint).with(body: /ClientInqRQ/).to_return(body: response_body, status: 200)
          end

          let(:applicant_ccms_reference_in_example_response) { "4390016" }

          it "updates the applicant_ccms_reference" do
            instance.call
            expect(submission.applicant_ccms_reference).to eq applicant_ccms_reference_in_example_response
          end

          it "sets the state to applicant_ref_obtained" do
            instance.call
            expect(submission.aasm_state).to eq "applicant_ref_obtained"
          end

          it "writes a history record" do
            expect { instance.call }.to change(SubmissionHistory, :count).by(1)
            expect(latest_history.from_state).to eq "case_ref_obtained"
            expect(latest_history.to_state).to eq "applicant_ref_obtained"
            expect(latest_history.success).to be true
            expect(latest_history.details).to be_nil
          end

          it "stores the reqeust body in the submission history record" do
            instance.call
            expect(latest_history.request).to be_soap_envelope_with(
              command: "clientbim:ClientInqRQ",
              transaction_id: "20190301030405123456",
              matching: [
                "<clientbio:Surname>#{applicant.last_name}</clientbio:Surname>",
                "<clientbio:FirstName>#{applicant.first_name}</clientbio:FirstName>",
              ],
            )
          end

          it "stores the response body in the submission history record" do
            instance.call
            expect(latest_history.response).to eq response_body
          end
        end

        shared_examples "applicant does not exist on CCMS" do
          before do
            # stub a post request
            stub_request(:post, endpoint).with(body: /ClientInqRQ/).to_return(body: empty_response_body, status: 200)
            stub_request(:post, endpoint).with(body: /ClientAddRQ/).to_return(body: success_add_applicant_response_body, status: 200)
          end

          it "sets the state to applicant_submitted" do
            expect_any_instance_of(CCMS::Requestors::ApplicantAddRequestor).to receive(:transaction_request_id).at_least(1).and_return("20190301030405123456")
            instance.call
            expect(submission.aasm_state).to eq "applicant_submitted"
          end

          it "writes a history record" do
            expect_any_instance_of(CCMS::Requestors::ApplicantAddRequestor).to receive(:transaction_request_id).at_least(1).and_return("20190301030405123456")
            expect { instance.call }.to change(SubmissionHistory, :count).by(2)
            expect(latest_history.from_state).to eq "case_ref_obtained"
            expect(latest_history.to_state).to eq "applicant_submitted"
            expect(latest_history.success).to be true
            expect(latest_history.details).to be_nil
          end

          it "stores the request body in the submission history record" do
            expect_any_instance_of(CCMS::Requestors::ApplicantAddRequestor).to receive(:transaction_request_id).at_least(1).and_return("20190301030405123456")
            instance.call
            expect(latest_history.request).to be_soap_envelope_with(
              command: "clientbim:ClientAddRQ",
              transaction_id: "20190301030405123456",
              matching: [
                "<common:Surname>#{applicant.last_name}</common:Surname>",
                "<common:FirstName>#{applicant.first_name}</common:FirstName>",
              ],
            )
          end

          it "stores the response body in the submission history record" do
            expect_any_instance_of(CCMS::Requestors::ApplicantAddRequestor).to receive(:transaction_request_id).at_least(1).and_return("20190301030405123456")
            instance.call
            expect(latest_history.response).to eq success_add_applicant_response_body
          end

          it "calls the AddApplicant service" do
            expect_any_instance_of(CCMS::Requestors::ApplicantAddRequestor).to receive(:transaction_request_id).at_least(1).and_return("20190301030405123456")
            expect(CCMS::Submitters::AddApplicantService).to receive(:new).and_call_original
            instance.call
          end
        end

        context "and applicant exists on CCMS but applicant details are not returned" do
          before { stub_request(:post, endpoint).with(body: /ClientInqRQ/).to_return(body: no_applicant_details_response_body, status: 200) }

          it_behaves_like "applicant does not exist on CCMS"
        end
      end

      context "when the operation is unsuccessful" do
        context "and an error is raised when searching for applicant" do
          let(:error) { [CCMS::CCMSError, Faraday::Error, Faraday::SoapError, StandardError] }
          let(:fake_error) { error.sample }

          before do
            allow_any_instance_of(CCMS::Requestors::ApplicantSearchRequestor).to receive(:call).and_raise(fake_error, "oops")
          end

          it "does not change the state" do
            expect { instance.call }.to raise_error(fake_error, "oops")
            expect(submission.aasm_state).to eq "case_ref_obtained"
          end

          it "records the error in the submission history" do
            expect { instance.call }.to raise_error(fake_error, "oops")
            expect(SubmissionHistory.count).to eq 1
            expect(latest_history.from_state).to eq "case_ref_obtained"
            expect(latest_history.to_state).to eq "failed"
            expect(latest_history.success).to be false
            expect(latest_history.details).to match(/#{error}/)
            expect(latest_history.details).to match(/oops/)
            expect(latest_history.request).to be_soap_envelope_with(
              command: "clientbim:ClientInqRQ",
              transaction_id: "20190301030405123456",
              matching: [
                "<clientbio:Surname>#{applicant.last_name}</clientbio:Surname>",
                "<clientbio:FirstName>#{applicant.first_name}</clientbio:FirstName>",
              ],
            )
          end
        end
      end
    end
  end
end
