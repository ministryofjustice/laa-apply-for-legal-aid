require "rails_helper"

module CCMS
  module Submitters
    RSpec.describe AddCaseService, :ccms do
      subject(:instance) { described_class.new(submission) }

      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_proceedings,
               :with_parties_mental_capacity,
               :with_domestic_abuse_summary,
               :with_chances_of_success,
               :with_everything_and_address,
               :with_passported_state_machine,
               :with_cfe_v5_result,
               :with_positive_benefit_check_result,
               explicit_proceedings: [:da001],
               set_lead_proceeding: :da001,
               office_id: office.id,
               populate_vehicle: true)
      end
      let(:applicant) { legal_aid_application.applicant }
      let(:office) { create(:office) }
      let(:submission) { create(:submission, :applicant_ref_obtained, legal_aid_application:) }
      let(:history) { SubmissionHistory.find_by(submission_id: submission.id) }
      let(:endpoint) { "https://ccms-soa-managed.laa-test.modernisation-platform.service.justice.gov.uk/soa-infra/services/default/CaseServices/CaseServices_ep" }
      let(:response_body) { ccms_data_from_file "case_add_response.xml" }

      let(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA001" } }

      before do
        create(:chances_of_success, :with_optional_text, proceeding:)
        stub_request(:post, endpoint).to_return(body: response_body, status: 200)
        allow_any_instance_of(CCMS::Requestors::CaseAddRequestor).to receive(:transaction_request_id).and_return("20190301030405123456")
      end

      around do |example|
        VCR.turned_off { example.run }
      end

      context "with passported application" do
        it "uses instance of CCMS::Requestors::CaseAddRequestor" do
          allow(CCMS::Requestors::CaseAddRequestor).to receive(:new).and_call_original
          instance.call
          expect(CCMS::Requestors::CaseAddRequestor).to have_received(:new).once
        end
      end

      context "with non-passported application" do
        let(:legal_aid_application) do
          create(:legal_aid_application,
                 :with_proceedings,
                 :with_chances_of_success,
                 :with_everything_and_address,
                 :with_non_passported_state_machine,
                 :with_cfe_v5_result,
                 office_id: office.id)
        end

        it "uses instance of CCMS::Requestors::NonPassportedCaseAddRequestor" do
          allow(CCMS::Requestors::NonPassportedCaseAddRequestor).to receive(:new).and_call_original
          instance.call
          expect(CCMS::Requestors::NonPassportedCaseAddRequestor).to have_received(:new).once
        end
      end

      context "with non-means-tested application" do
        let(:legal_aid_application) do
          create(:legal_aid_application,
                 :with_under_18_applicant,
                 :with_proceedings,
                 :with_skipped_benefit_check_result,
                 :with_non_means_tested_state_machine,
                 :with_cfe_empty_result,
                 :with_opponent,
                 :with_chances_of_success,
                 office_id: office.id)
        end

        it "uses instance of CCMS::Requestors::NonMeansTestedCaseAddRequestor" do
          allow(CCMS::Requestors::NonMeansTestedCaseAddRequestor).to receive(:new).and_call_original
          instance.call
          expect(CCMS::Requestors::NonMeansTestedCaseAddRequestor).to have_received(:new).once
        end
      end

      context "when operation successful" do
        it "sets state to case_submitted" do
          instance.call
          expect(submission.aasm_state).to eq "case_submitted"
        end

        it "records the transaction id of the request" do
          instance.call
          expect(submission.case_add_transaction_id).to eq "20190301030405123456"
        end

        context "with documents to upload" do
          let(:submission) { create(:submission, :document_ids_obtained, legal_aid_application:) }

          it "writes a history record" do
            expect { instance.call }.to change(SubmissionHistory, :count).by(1)
            expect(history.from_state).to eq "document_ids_obtained"
            expect(history.to_state).to eq "case_submitted"
            expect(history.success).to be true
            expect(history.details).to be_nil
          end

          it "stores the reqeust body in the submission history record" do
            instance.call
            expect(history.request).to be_soap_envelope_with(
              command: "casebim:CaseAddRQ",
              transaction_id: "20190301030405123456",
              matching: [
                "<casebio:PreferredAddress>CASE</casebio:PreferredAddress>",
                "<casebio:ProviderOfficeID>#{legal_aid_application.office.ccms_id}</casebio:ProviderOfficeID>",
              ],
            )
          end

          it "stores the response body in the submission history record" do
            instance.call
            expect(history.response).to eq response_body
          end
        end

        context "without documents to upload" do
          it "writes a history record" do
            expect { instance.call }.to change(SubmissionHistory, :count).by(1)
            expect(history.from_state).to eq "applicant_ref_obtained"
            expect(history.to_state).to eq "case_submitted"
            expect(history.success).to be true
            expect(history.details).to be_nil
          end

          it "stores the request body in the submission history record" do
            instance.call
            expect(history.request).to be_soap_envelope_with(
              command: "casebim:CaseAddRQ",
              transaction_id: "20190301030405123456",
              matching: [
                "<casebio:ProviderOfficeID>#{legal_aid_application.office.ccms_id}</casebio:ProviderOfficeID>",
              ],
            )
          end

          it "writes the response body to the history record" do
            instance.call
            expect(history.response).to eq response_body
          end
        end
      end

      context "when operation encounters error" do
        context "with error while adding a case" do
          let(:error) { [CCMS::CCMSError, Faraday::Error, Faraday::SoapError, StandardError] }
          let(:fake_error) { error.sample }

          before do
            allow_any_instance_of(CCMS::Requestors::CaseAddRequestor).to receive(:call).and_raise(fake_error, "oops")
          end

          it "does not change the state" do
            expect { instance.call }.to raise_error(fake_error, "oops")
            expect(submission.aasm_state).to eq "applicant_ref_obtained"
          end

          it "records the error in the submission history" do
            expect { instance.call }.to raise_error(fake_error, "oops")
            expect(SubmissionHistory.count).to eq 1
            expect(history.from_state).to eq "applicant_ref_obtained"
            expect(history.to_state).to eq "failed"
            expect(history.success).to be false
            expect(history.details).to match(/#{error}/)
            expect(history.details).to match(/oops/)
            expect(history.request).to be_soap_envelope_with(
              command: "casebim:CaseAddRQ",
              transaction_id: "20190301030405123456",
              matching: [
                "<casebio:PreferredAddress>CASE</casebio:PreferredAddress>",
                "<casebio:ProviderOfficeID>#{legal_aid_application.office.ccms_id}</casebio:ProviderOfficeID>",
              ],
            )
          end
        end

        context "when an unsuccessful response is received from CCMS" do
          let(:response_body) { ccms_data_from_file "case_add_response_failure.xml" }

          it "does not change state" do
            expect { instance.call }.to raise_error(CCMS::CCMSUnsuccessfulResponseError, "AddCaseService failed with unsuccessful response for submission: #{submission.id}")
            expect(submission.aasm_state).to eq "applicant_ref_obtained"
          end

          it "records the error in the submission history" do
            expect { instance.call }.to raise_error(CCMS::CCMSUnsuccessfulResponseError, "AddCaseService failed with unsuccessful response for submission: #{submission.id}")
            expect(SubmissionHistory.count).to eq 1
            expect(history.from_state).to eq "applicant_ref_obtained"
            expect(history.to_state).to eq "failed"
            expect(history.success).to be false
          end

          it "stores the reqeust body in the submission history record" do
            expect { instance.call }.to raise_error(CCMS::CCMSUnsuccessfulResponseError, "AddCaseService failed with unsuccessful response for submission: #{submission.id}")
            expect(history.request).to be_soap_envelope_with(
              command: "casebim:CaseAddRQ",
              transaction_id: "20190301030405123456",
              matching: [
                "<casebio:ProviderOfficeID>#{legal_aid_application.office.ccms_id}</casebio:ProviderOfficeID>",
              ],
            )
          end

          it "stores the response body in the submission history record" do
            expect { instance.call }.to raise_error(CCMS::CCMSUnsuccessfulResponseError, "AddCaseService failed with unsuccessful response for submission: #{submission.id}")
            expect(history.response).to eq response_body
          end
        end
      end
    end
  end
end
